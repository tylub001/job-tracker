# Job Tracker & PDF Automation Toolkit

A backend-focused utility suite for generating, validating, and merging PDF job tickets. Built in Perl with MySQL integration, this project demonstrates real-world automation patterns used in print shops, operations teams, and internal business systems.

---

## Features

### PDF Job Ticket Generator
Creates structured, print-ready job tickets using data pulled from a MySQL database.

- Connects to a MySQL instance using DBI  
- Retrieves job metadata dynamically  
- Generates clean, formatted PDFs using PDF::API2  
- Handles authentication plugin mismatches and connection errors gracefully  

---

### PDF Merge Utility
Combines multiple PDFs into a single output file.

- Built with PDF::API2 for maximum compatibility  
- Validates input files before merging  
- Includes production-style logging and exit codes  
- Supports batch workflows and automation pipelines  

---

### PDF Validator
Ensures PDFs are structurally sound before processing.

- Checks file existence and readability  
- Verifies valid PDF headers (`%PDF-`)  
- Confirms the file can be parsed by PDF::API2  
- Ensures the PDF contains at least one page  
- Returns clear, meaningful exit codes for automation  

---

### Cron Automation
Automates daily generation of all job tickets using scheduled scripts and logging at 3:55PM

- Uses run_generate_all.sh as the cron entrypoint
- Calls generate_all_tickets.pl to build all PDF job tickets
- Writes timestamped logs to a dedicated logs/ directory
- Integrates cleanly with batch workflows and automation pipelines

### Logs Folder
Stores all cron‑generated logs for auditing and debugging.

- Automatically creates daily log files
- Captures start/end timestamps, errors, and exit codes
- Helps monitor long‑running or scheduled tasks

---

## Tech Stack

- **Perl** (PDF::API2, DBI)  
- **MySQL** (schema design, user permissions, plugin configuration)  
- **WSL / Ubuntu**  
- **CLI tooling & automation**  
- **Cron (scheduled automation)**

---

## Author

**Created by:** Brittany Tylutke  
**LinkedIn:** https://www.linkedin.com/in/brittany-tylutke-27418a34a
