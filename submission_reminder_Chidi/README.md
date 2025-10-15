# submission_reminder app (local copy)

To run the app:
1. cd into the scripts folder:
   cd scripts
2. make sure startup.sh is executable:
   chmod +x startup.sh
3. run:
   ./startup.sh

Configuration:
- config/config.env contains ASSIGNMENT, DEADLINE, and REMINDER_MESSAGE

Data:
- data/submissions.txt contains student records in format:
  Name,status  (status is 'submitted' or 'pending')
