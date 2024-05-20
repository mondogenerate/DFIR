# Resource
https://learnsentinel.blog/2021/11/25/detecting-multistage-attacks-in-microsoft-sentinel/

# Summary of activities completed by privileged users
//Create a daily summary of activities completed by your Azure AD privileged users

//Data connector required for this query - Azure Active Directory - Audit Logs
//Data connector required for this query - Microsoft Sentinel UEBA

let timerange=30d;
IdentityInfo
| where TimeGenerated > ago(21d)
| summarize arg_max(TimeGenerated, *) by AccountUPN
| where isnotempty(AssignedRoles)
| where AssignedRoles != "[]"
| project Actor=AccountUPN
| join kind=inner (
    AuditLogs
    | where TimeGenerated > ago(timerange)
    | extend Actor = tostring(parse_json(tostring(InitiatedBy.user)).userPrincipalName)
    | where isnotempty(Actor)
    )
    on Actor
| summarize AdminActivity = make_list(OperationName) by Actor, startofday(TimeGenerated)

# Correlate Users with User Risk events where Authentication info was added or deleted
let starttime = 45d;
let timeframe = 4h;
AADUserRiskEvents
| where TimeGenerated > ago(starttime)
| where RiskDetail != "aiConfirmedSigninSafe"
| project RiskTime=TimeGenerated, UserPrincipalName, RiskEventType, RiskLevel, Source
| join kind=inner (
    AuditLogs
    | where OperationName in ("User registered security info", "User deleted security info")
    | where Result == "success"
    | extend UserPrincipalName = tostring(TargetResources[0].userPrincipalName)
    | project SecurityInfoTime=TimeGenerated, OperationName, UserPrincipalName, Result, ResultReason)
    on UserPrincipalName
| project RiskTime, SecurityInfoTime, UserPrincipalName, RiskEventType, RiskLevel, Source, OperationName, ResultReason
| where (SecurityInfoTime - RiskTime) between (0min .. timeframe)

# When a user holding a privileged role triggers an Azure AD risk event, retrieve the operations completed by that user

//When a user holding a privileged role triggers an Azure AD risk event, retrieve the operations completed by that user
//Lookup the IdentityInfo table for any users holding a privileged role

//Data connector required for this query - Azure Active Directory - Audit Logs
//Data connector required for this query - Microsoft Sentinel UEBA

let privusers=
    IdentityInfo
    | where TimeGenerated > ago(21d)
    | summarize arg_max(TimeGenerated, *) by AccountUPN
    | where isnotempty(AssignedRoles)
    | where AssignedRoles != "[]"
    | distinct AccountUPN;
AADUserRiskEvents
| where TimeGenerated > ago (7d)
| where UserPrincipalName in (privusers)
| where RiskDetail != "aiConfirmedSigninSafe"
| project RiskTime=TimeGenerated, UserPrincipalName
| join kind=inner
    (
    AuditLogs
    | where TimeGenerated > ago(7d)
    | extend UserPrincipalName = tostring(parse_json(tostring(InitiatedBy.user)).userPrincipalName)
    )
    on UserPrincipalName
| project-rename OperationTime=TimeGenerated
| project
    RiskTime,
    OperationTime,
    ['Time Between Events']=datetime_diff("minute", OperationTime, RiskTime),
    OperationName,
    Category,
    CorrelationId

# Check Privileged Roles with No Activity
//Find users who hold a privileged Azure AD role but haven't completed any activities in Azure AD for 45 days

//Data connector required for this query - Azure Active Directory - Audit Logs
//Data connector required for this query - Microsoft Sentinel UEBA

//Lookup the IdentityInfo table for any users holding a privileged role
IdentityInfo
| where TimeGenerated > ago(91d)
| summarize arg_max(TimeGenerated, *) by AccountUPN
| where isnotempty(AssignedRoles)
| where AssignedRoles != "[]"
| project UserPrincipalName=AccountUPN, AssignedRoles
| join kind=leftanti (
    AuditLogs
    | where TimeGenerated > ago(45d)
    | extend UserPrincipalName = tostring(parse_json(tostring(InitiatedBy.user)).userPrincipalName)
    | where isnotempty(UserPrincipalName)
    | distinct UserPrincipalName
    )
    on UserPrincipalName