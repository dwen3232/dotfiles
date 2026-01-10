---
name: jira
description: Use when interacting with Jira
---

# Jira CLI Skill

Uses `acli` (Atlassian CLI) for Jira operations. Authentication: `acli jira auth login --web`

The common tasks below are EXAMPLES of things you may be asked to do. You DO NOT need to follow their formats exactly 
## Common Tasks

**Get a ticket:**
```bash
acli jira workitem view DO-123
```

**Update a ticket:**
```bash
acli jira workitem edit DO-123 --assignee username --comment "text"
```

**List tickets assigned to me:**
```bash
acli jira workitem search --jql "assignee = currentUser() AND status NOT IN ('Accepted', 'Closed', 'In Production', 'Not Doing')" --paginate --csv
```

**Other useful commands:**
- `acli jira workitem search --jql "JQL_QUERY" --csv` - Search with JQL
- `acli jira workitem transition DO-123 --status "In Progress" --csv` - Change status
- `acli jira workitem assign DO-123 --assignee username --csv` - Assign ticket

**Common Story Statuses:**
- To Do
- In Progress
- Ready for Code Review
- Ready for Acceptance
- Accepted
- In Production
- Closed
- Icebox
- Not Doing

**Filtering Guidelines:**
- **DEFAULT BEHAVIOR**: Unless explicitly requested otherwise, ONLY show stories that are NOT completed
- Completed statuses to exclude: Accepted, Closed, In Production, Not Doing
- Use status-based filtering: `status NOT IN ('Accepted', 'Closed', 'In Production', 'Not Doing')`
- For specific statuses, use: `status = "In Progress"` or `status IN ("To Do", "In Progress")`

**IMPORTANT:** ALWAYS use `--csv` flag for all commands to get structured output.

## Documentation

Official docs: https://developer.atlassian.com/cloud/acli/

If you encounter errors or need to understand command options, use `acli jira workitem --help` or `acli jira workitem <command> --help`.
