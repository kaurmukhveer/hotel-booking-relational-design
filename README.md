# hotel-booking-relational-design
Enterprise relational schema and Enhanced Entity Relationship architecture design for a multi-tier hotel booking platform.
# Hotel Management & Booking Database System 🗄️

## 📌 Project Overview
This project contains the database design for a Hotel Management and Booking System. It was built as a group project for the **CSI 2132 (Database I) course at the University of Ottawa**. 

The goal of the project was to design a clean, organized system to manage information for hotel chains, physical rooms, customer bookings, employee roles, and customer payments. 

---

### 🗺️ Database Structure Diagram
This diagram shows how our 10 database tables link together using matching IDs (Primary Keys and Foreign Keys):

![Relational Schema](./database-schema.png)

---

### 📄 Detailed Project Report (PDF)
You can find our full project report right here in the main folder:
* 📁 **[CSI2132_Project_Deliverable_1.pdf](./CSI2132_Project_Deliverable_1.pdf):** This document includes our complete grading submission, featuring:
    * **Rules & Logic:** Descriptions explaining why each table was created (such as how room prices are calculated and how old bookings are archived).
    * **Table Relationships:** Explanations of how tables connect (for example, how one hotel chain can own many different hotels).
    * **Data Rules:** Charts showing exactly which fields are mandatory, unique, or must follow a specific text format.

---

### 🏛️ Key Database Features

Our design focuses on keeping database information accurate and safe:
* **Strong and Weak Tables:** We separated independent data (like *Customers* or *Hotel Chains*) from dependent data (like *Rooms* or *Payments* which cannot exist without a hotel or a customer).
* **Automatic Cleanup:** We set up cleanup rules (`ON DELETE CASCADE`). This means if a hotel chain is deleted from the system, all of its hotels and rooms are automatically cleaned up too, preventing broken data.
* **Smart Input Rules:** We added rules to double-check information before it enters the database. For example, verifying Canadian SIN or SSN formats, ensuring a checkout date comes *after* a check-in date, and forcing payment methods to match strict options (*Credit, Debit, Cash, Online, Transfer*).

---

### 🔍 Future Improvements (What We Learned)

Looking back at our design, here is how we would improve the system to make it run faster in a real company environment:

1. **Simpler Dates:** Our initial design splits dates into separate columns for Year, Month, and Day. In a real system, we would combine these into a single native `TIMESTAMP` column. This saves computer memory and makes it much easier to calculate dates (like calculating how many days a guest stayed).
2. **Removing Redundant Info:** Our `Room` table records both the Hotel ID and the Hotel Chain ID. Since every room belongs to a specific hotel, the database can easily figure out the chain through the hotel itself. Removing the chain ID from the room table saves storage space.
3. **Adding a Search Index:** To make the database run faster when thousands of people use it, we would add "indexes" to the `Check_In_Date` and `Customer_ID` columns. This works like an index at the back of a textbook, helping the system find data instantly instead of reading the whole table from scratch.
