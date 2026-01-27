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

## Tech Stack

- **Perl** (PDF::API2, DBI)  
- **MySQL** (schema design, user permissions, plugin configuration)  
- **WSL / Ubuntu**  
- **CLI tooling & automation**  

---

## Author

**Created by:** Brittany Tylutke  
**LinkedIn:** https://www.linkedin.com/in/brittany-tylutke-27418a34a
