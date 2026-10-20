# Worker ID Terminology Rule

Whenever you encounter or display any identifier for users/employees:
- Always use **"Worker ID"** instead of "Civil ID".
- In Arabic user-facing text, use **"الرقم الوظيفي"** (or "معرف الموظف") instead of "الرقم المدني".
- Never display "Civil ID" to users in any form, UI label, table header, dialog, snackbar, or error message.
- Keep backend internal database columns and API schemas (`civil_id`) compatible unless explicitly requested by the user to refactor the database.
