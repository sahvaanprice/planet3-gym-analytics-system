/* 
01_create_table.sql
Project: Planet 3 Gym Analytics System

Prupose:Creates all relational tables required for the Planet 3 operational database,
including members, trainers, subscriptions, payments, scheduling, and equipment tracking. 
*/

CREATE TABLE Employee ( EMP_ID integer primary key, EMP_FName varchar(50), EMP_LName varchar(50), EMP_Phone varchar(50), SUPERVISOR_ID integer FOREIGN KEY (SUPERVISOR_ID) REFERENCES Employee(EMP_ID) ); 

CREATE TABLE Equipment ( Equip_ID integer , Equip_Status varchar(50), Last_Check_Date Date, EMP_ID integer, PRIMARY KEY (Equip_ID, Last_Check_Date), FOREIGN KEY (EMP_ID) REFERENCES Employee(EMP_ID) ); 

CREATE TABLE Member ( MEM_ID integer primary key, Mem_FName varchar(50), Mem_LName varchar(50), Mem_City varchar(50), Mem_Phone varchar(50), SUB_ID integer, EMP_ID integer ); 

CREATE TABLE Normal_Sub ( NORM_ID integer primary key, Sub_Date Date, SUB_ID integer, FOREIGN KEY (SUB_ID) REFERENCES Subscription(SUB_ID) ); 

CREATE TABLE VIP_Sub ( VIP_ID integer primary key, VIP_Sub_Date Date, SUB_ID integer, FOREIGN KEY (SUB_ID) REFERENCES Subscription(SUB_ID) ); 

CREATE TABLE Trainer ( TRAINER_ID integer primary key, Trainer_FName varchar(50), Trainer_LName varchar(50), T_Phone varchar(50) ); 

CREATE TABLE Class ( CLASS_ID integer primary key, REG_ID integer, TRAINER_ID integer, Class_Names varchar(50), Class_Date DATE, Class_Time TIME, Class_Capacity integer, FOREIGN KEY (TRAINER_ID) REFERENCES Trainer(TRAINER_ID) ); 

CREATE TABLE Registration ( REG_ID integer primary key, Registered_Amt integer, MEM_ID integer, CLASS_ID integer, FOREIGN KEY (MEM_ID) REFERENCES Member(MEM_ID), FOREIGN KEY (CLASS_ID) REFERENCES Class(CLASS_ID) ); 

CREATE TABLE Appointment ( APT_ID integer primary key, APT_Date Date, APT_Time time, MEM_ID integer, TRAINER_ID integer, FOREIGN KEY (MEM_ID) REFERENCES Member(MEM_ID), FOREIGN KEY (TRAINER_ID) REFERENCES Trainer(TRAINER_ID) ); 

CREATE TABLE Payment ( PAYMENT_ID integer, Invoice varchar(50), Due_Date DATE, Paid_Date DATE, Paid_Amount decimal(6,2), SUB_ID integer, PRIMARY KEY (PAYMENT_ID, SUB_ID), FOREIGN KEY (SUB_ID) REFERENCES Subscription(SUB_ID) ); 
