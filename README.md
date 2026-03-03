# CSCI331 — HW4 (Chapters 4 & 5) — PPG_6  
**Student:** Amrina Qayyum  
**Group Category:** PairProgrammingGroups  
**Group Name:** PPG_6  
**Due:** Mar 4, 2026 (11:59 PM)

---

## Project Summary
This homework includes:
- **Chapter 4:** Subqueries  
- **Chapter 5:** Table Expressions (Derived Tables, CTEs, Views, APPLY)

**Database usage (as required):**
- **TSQLV6** → used only for testing/debugging  
- **Northwinds2024Student** → used for final execution/submission  

---

## Problem Proposition (Northwinds)
Northwinds needs visibility into order activity and shipping cost (freight) trends over time. The business must understand how many orders are placed and how freight changes across time periods to plan operations and control shipping expenses. Using the Northwinds2024Student database, this project produces SQL reports using subqueries and table expressions, and includes a fiscal year quarter summary that reports total orders and total freight by federal FY quarter from newest to oldest.

---
---

## Repository Contents
```text
sql/
├─ TSQLV6/
│  └─ TSQLV6 — Chapter 4 + Chapter 5 + FY Quarter (FULL ANSWERS).sql
└─ Northwinds2024Student/
   └─ Individual_PPG_6_HW4_AmrinaQayyum_Northwinds.sql

report/
├─ HW4_Report_AmrinaQayyum.pdf
├─ todo.png
└─ gantt.png
---

## How to Run (SSMS)

### 1) Restore Databases
Restore both backups in SSMS:
- `TSQLV6.bak`
- `Northwinds2024Student.bak`

### 2) Run TSQLV6 (Testing)
1. Open SSMS and select database **TSQLV6**
2. Run:
   - `sql/TSQLV6/TSQLV6 — Chapter 4 + Chapter 5 + FY Quarter (FULL ANSWERS).sql`

### 3) Run Northwinds (Final Submission)
1. Select database **Northwinds2024Student**
2. Run:
   - `sql/Northwinds2024Student/Individual_PPG_6_HW4_AmrinaQayyum_Northwinds.sql`

✅ The **FY Quarter scalar function + report** is included and outputs FY quarters (newest → oldest) with:
- TotalOrders
- TotalFreight

---

## Planning Evidence (To-Do + Gantt)
Planning file included:
- `todo.png`
-  `gantt.png`


This was shown in the MP4 walkthrough as project planning proof.

---

## Presentation (MP4) — YouTube Link
Requires video submission via **YouTube**.

MP4 walkthrough includes:
1) Intro (PPG_6 + HW4)  
2) Proposition (Northwinds)  
3) To-Do + Gantt shown  
4) Demo: TSQLV6 testing (short)  
5) Demo: Northwinds final queries (main)  
6) FY quarter output table  
7) NACE + LLM statement  
8) GitHub repo page  

---

## NACE Competencies Used
- **Teamwork:** Coordinated tasks and reviewed SQL work  
- **Communication:** Explained steps/results clearly in the MP4  
- **Critical Thinking:** Debugged schema/column issues and corrected SQL  
- **Technology:** Used SSMS/SQL Server, GitHub, and YouTube  
- **Professionalism & Leadership:** Followed rules, naming conventions, and consolidated deliverables  

---

## LLM / AI Use Statement
We took help from AI for our better understanding and when we faced problems. AI/LLM was used to support learning, debugging, and improving documentation clarity, while ensuring the final SQL solutions were executed and verified in the required databases.

