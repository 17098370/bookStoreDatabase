CREATE DATABASE IDB_ASSIGNMENT

USE IDB_ASSIGNMENT

CREATE TABLE Publisher -- Book publisher's profile details
(
	Publisher_ID VARCHAR(5) PRIMARY KEY NOT NULL,
	First_Name VARCHAR(20) NOT NULL,
	Last_Name VARCHAR(20) NOT NULL,
	Contact_Number VARCHAR(11) NOT NULL,
	Company_Name VARCHAR(50) NOT NULL,
	House_No VARCHAR(5) NOT NULL,
	Address_Line1 VARCHAR(50) NOT NULL,
	Address_Line2 VARCHAR(50) NOT NULL,
	Post_Code VARCHAR(10) NOT NULL,
	City VARCHAR(50) NOT NULL,
	City_State VARCHAR(50) NOT NULL, 
	Country VARCHAR(50) NOT NULL
)

INSERT INTO Publisher VALUES('P01','Nancy','Bulter','60125463765','Arcade Publishing','75','Jalan Pandan Perdana 16','Pandan Perdana','56100','Cheras','Kuala Lumpur','Malaysia')
INSERT INTO Publisher VALUES('P02','Jamie','McGuire','60136765433','Da Capo Press','13A','Jalan Parit Raja 6 ','Parit Raja','86400','Batu Pahat','Johor','Malaysia')
INSERT INTO Publisher VALUES('P03','Bram','Stoker','60164535454','Hodder Headline','123','Jalan Technokrat 5','Taman Technokrat','63000','Cyberjaya','Selangor','Malaysia')
INSERT INTO Publisher VALUES('P04','Stephen','King','60178967500','Baker Book House','15','Jalan Ramal 2','Taman Ramal Luar','43200','Kajang','Selangor','Malaysia')
INSERT INTO Publisher VALUES('P05','William','Gibson','60105988988','Prince Hall','21','Jalan Cheras Indah 5','Taman Cheras Indah','56100','Cheras','Kuala Lumpur','Malaysia')

SELECT * FROM Publisher

---------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE Book -- Books details
(
	Book_ID VARCHAR(5) PRIMARY KEY NOT NULL,
	Publisher_ID VARCHAR(5) REFERENCES Publisher(Publisher_ID) NOT NULL,
	ISBN VARCHAR(15) NOT NULL,
	Book_Name VARCHAR(50) NOT NULL,
	Genres VARCHAR(20) NOT NULL,
	Author_Name VARCHAR(50) NOT NULL,
	Initial_Price DECIMAL(10,2) NOT NULL,
	Selling_Price AS CONVERT(DECIMAL(10,2),(Initial_Price * 0.2) + Initial_Price),
	Inventory_Quantity INT NOT NULL,
	Effective_Date DATE NOT NULL,
)

INSERT INTO Book(Book_ID,Publisher_ID,ISBN,Book_Name,Genres,Author_Name,Initial_Price,Inventory_Quantity,Effective_Date) VALUES
('B01','P01','9780553212471','Frankenstein','Horror','Felix Kjellberg',40.5,10,'2016-3-10'),
('B02','P01','8601406405448','Fifty Shades of Grey','Romantic','Marzia Bisognin',55.9,20,'2016-3-10'),
('B03','P04','9780812550702','Ender''s Game','Science Fiction','Ian Hecox',43.5,10,'2016-3-10'),
('B04','P02','9781476719078','Beautiful Disaster','Romantic','Anthony Padilla',35.4,10,'2016-3-10'),
('B05','P02','9780553254013','The Guns of August','History','Lynne Barrett',50,10,'2016-5-5'),
('B06','P03','9780393970128','Dracula','Horror','Michele Bardsley',48,10,'2016-5-5'),
('B07','P04','9780753827666','Gone Girl','Mystery','James Robert Baker',49,10,'2016-5-5'),
('B08','P04','9780140430967','The Woman in White','Mystery','Alessandro Baricco',52.3,10,'2016-5-5'),
('B09','P05','9780521618700','Romeo and Juliet','Drama','Mohammed al-Baydhaq',42,20,'2016-5-5'),
('B10','P05','9780963339744','The Girl Next Door','Horror','Tony Barrell',70,20,'2016-6-23'),
('B11','P05','9788183222051','The Secret','Non-Fiction','Helen Bannerman ',65,20,'2016-6-23'),
('B12','P05','9780316097789','Dare Me','Mystery','Rick Bayan',68,10,'2016-6-23')

SELECT Book_ID,Publisher_ID,ISBN,Book_Name,Genres,Author_Name,FORMAT(Initial_Price,'c','ms-MY') AS Initial_Price,FORMAT(Selling_Price,'c','ms-MY') AS Selling_Price,Inventory_Quantity,Effective_Date FROM Book

---------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE Invoice -- Invoice issued by publisher to e-bookstore manager
(
	Invoice_ID VARCHAR(5) PRIMARY KEY NOT NULL,
	Publisher_ID VARCHAR(5) REFERENCES Publisher(Publisher_ID) NOT NULL,
	Invoice_Date DATE NOT NULL, --Date of books ordered by Manager from Publisher
	Received_Date DATE, --Date of ordered books received from Publisher
	Payment_Status VARCHAR(6) NOT NULL,
	--Total_Price DECIMAL(10,2) --Created using FUNCTION
)

INSERT INTO Invoice VALUES('IN01','P01','2016-4-22','2016-4-25','Paid')
INSERT INTO Invoice VALUES('IN02','P02','2016-6-14','2016-6-20','Paid')
INSERT INTO Invoice VALUES('IN03','P03','2016-9-10','2016-9-13','Paid')
INSERT INTO Invoice VALUES('IN04','P04','2016-9-29',NULL,'Unpaid')
INSERT INTO Invoice VALUES('IN05','P05','2016-10-13','2016-10-18','Unpaid')
INSERT INTO Invoice VALUES('IN06','P05','2016-11-1','2016-11-10','Unpaid')

GO
CREATE FUNCTION dbo.GetInvoice_TotalPrice(@id VARCHAR(5))
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @ret DECIMAL(10,2)
	SELECT @ret = SUM(ID.Quantity * ID.Unit_Price)
	FROM Invoice I
	INNER JOIN Invoice_Details ID
		ON I.Invoice_ID = ID.Invoice_ID
	WHERE (ID.Shipment_Status = 'Delivered' OR ID.Shipment_Status = 'Shipping') AND I.Invoice_ID = @id

	 IF (@ret IS NULL)
		SET @ret = 0
	RETURN @ret
END
GO

ALTER TABLE Invoice
ADD Total_Price AS dbo.GetInvoice_TotalPrice(Invoice_ID)

SELECT Invoice_ID,Publisher_ID,Invoice_Date,Payment_Status,FORMAT(Total_Price,'c','ms-MY') AS Total_Price FROM Invoice

---------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE Invoice_Details -- Books ordered details and shipment status
(
	Invoice_Details_ID VARCHAR(5) PRIMARY KEY NOT NULL,
	Invoice_ID VARCHAR(5) REFERENCES Invoice(Invoice_ID) NOT NULL,
	ISBN VARCHAR(15) NOT NULL,
	Book_Name VARCHAR(50) NOT NULL,
	Quantity INT NOT NULL,
	Unit_Price DECIMAL(10,2) NOT NULL, --Initial Price
	Shipment_Status VARCHAR(10) NOT NULL
)

INSERT INTO Invoice_Details VALUES('M01','IN01','9780553212471','Frankenstein',30,40.5,'Delivered')
INSERT INTO Invoice_Details VALUES('M02','IN01','8601406405448','Fifty Shades of Grey',20,55.9,'Delivered')
INSERT INTO Invoice_Details VALUES('M03','IN02','9780140385724','The Outsiders',30,53.2,'Delivered')
INSERT INTO Invoice_Details VALUES('M04','IN02','9781476719078','Beautiful Disaster',30,35.4,'Delivered')
INSERT INTO Invoice_Details VALUES('M05','IN03','9780553254013','The Guns of August',10,50,'Delivered')
INSERT INTO Invoice_Details VALUES('M06','IN04','9780393970128','Dracula',10,48,'Shipping')
INSERT INTO Invoice_Details VALUES('M07','IN04','9780753827666','Gone Girl',20,49,'No Stock')
INSERT INTO Invoice_Details VALUES('M08','IN04','9780812550702','Ender''s Game',20,43.5,'Shipping')
INSERT INTO Invoice_Details VALUES('M09','IN05','9780753827666','Gone Girl',20,49,'Delivered')
INSERT INTO Invoice_Details VALUES('M10','IN05','9780140430967','The Woman in White',20,52.3,'Delivered')
INSERT INTO Invoice_Details VALUES('M11','IN05','9780521618700','Romeo and Juliet',20,42,'Delivered')
INSERT INTO Invoice_Details VALUES('M12','IN05','9780141328294','Thirteen Reasons Why',10,56.9,'Delivered')
INSERT INTO Invoice_Details VALUES('M13','IN06','9788183222051','The Secret',30,65,'Delivered')
INSERT INTO Invoice_Details VALUES('M14','IN06','9780547577098','Number the Stars',10,42.5,'No Stock')

SELECT Invoice_Details_ID,Invoice_ID,ISBN,Book_Name,Quantity,FORMAT(Unit_Price,'c','ms-MY') AS Unit_Price,Shipment_Status FROM Invoice_Details

---------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE Customer -- Customer's profile details
(
	Customer_ID VARCHAR(5) PRIMARY KEY NOT NULL,
	First_Name VARCHAR(20) NOT NULL,
	Last_Name VARCHAR(20) NOT NULL,
	Contact_Number VARCHAR(11) NOT NULL,
	House_No VARCHAR(5) NOT NULL,
	Address_Line1 VARCHAR(50) NOT NULL,
	Address_Line2 VARCHAR(50) NOT NULL,
	Post_Code VARCHAR(10) NOT NULL,
	City VARCHAR(50) NOT NULL,
	City_State VARCHAR(50) NOT NULL,
	Country VARCHAR(50) NOT NULL
)

INSERT INTO Customer VALUES('C01','Colye','Lim','60178598685','18','Jalan Wira Indah 13','Taman Wira Indah','08000','Sungai Petani','Kedah','Malaysia')
INSERT INTO Customer VALUES('C02','Yeu Jie','Lim','60145784657','6','Jalan Hulubalang 2','Taman Ungku Tun Aminah','81300','Skudai','Johor','Malaysia')
INSERT INTO Customer VALUES('C03','Rachel','Lim','60145876954','12A','Jalan Bukit Prima 3A','Taman Bukit Prima','43200','Cheras','Selangor','Malaysia')
INSERT INTO Customer VALUES('C04','Aloysius','Chow','60137851003','21','Jalan Putri Jaya 9','Taman Putri Jaya','43200','Cheras','Selangor','Malaysia')
INSERT INTO Customer VALUES('C05','Mandy','Lam','60178585988','15C','Jalan Barat','Vista Komanwel','57000','Bukit Jalil','Kuala Lumpur','Malaysia')
INSERT INTO Customer VALUES('C06','Andrew','Goh','60165478799','60A','Jalan Cheras Indah 16','Taman Cheras Indah','56100','Cheras','Kuala Lumpur','Malaysia')

SELECT * FROM Customer

---------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE Customer_Cart -- Customer's interested books
(
	Customer_Cart_ID VARCHAR(5) PRIMARY KEY NOT NULL,
	Customer_ID VARCHAR(5) REFERENCES Customer(Customer_ID) NOT NULL,
	--Total_Price DECIMAL(10,2) --Created using FUNCTION
)

INSERT INTO Customer_Cart VALUES('CC01','C01')
INSERT INTO Customer_Cart VALUES('CC02','C02')
INSERT INTO Customer_Cart VALUES('CC03','C04')
INSERT INTO Customer_Cart VALUES('CC04','C05')
INSERT INTO Customer_Cart VALUES('CC05','C06')

GO
CREATE FUNCTION dbo.GetCustomerCart_TotalPrice(@id VARCHAR(5))
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @ret DECIMAL(10,2)
	SELECT @ret = SUM(CD.Quantity * B.Selling_Price)
	FROM Book B
	INNER JOIN Cart_Details CD
		ON B.Book_ID = CD.Book_ID
	INNER JOIN Customer_Cart CC
		ON CD.Customer_Cart_ID = CC.Customer_Cart_ID 
	WHERE CC.Customer_Cart_ID = @id

	 IF (@ret IS NULL)
		SET @ret = 0
	RETURN @ret
END
GO

ALTER TABLE Customer_Cart
ADD Total_Price AS dbo.GetCustomerCart_TotalPrice(Customer_Cart_ID)

SELECT Customer_Cart_ID,Customer_ID,FORMAT(Total_Price,'c','ms-MY') AS Total_Price FROM Customer_Cart

---------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE Cart_Details -- Customer's interested books details
(
	Customer_Cart_ID VARCHAR(5) REFERENCES Customer_Cart(Customer_Cart_ID) NOT NULL,
	Book_ID VARCHAR(5) REFERENCES Book(Book_ID) NOT NULL,
	PRIMARY KEY(Customer_Cart_ID,Book_ID),
	Quantity INT NOT NULL
)

INSERT INTO Cart_Details VALUES('CC01','B01',1)
INSERT INTO Cart_Details VALUES('CC01','B02',1)
INSERT INTO Cart_Details VALUES('CC02','B04',2)
INSERT INTO Cart_Details VALUES('CC03','B01',1)
INSERT INTO Cart_Details VALUES('CC03','B06',1)
INSERT INTO Cart_Details VALUES('CC03','B07',1)
INSERT INTO Cart_Details VALUES('CC04','B10',1)
INSERT INTO Cart_Details VALUES('CC05','B12',1)

SELECT * FROM Cart_Details

---------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE Customer_Purchase -- Customer's books purchased
(
	Purchase_ID VARCHAR(5) PRIMARY KEY NOT NULL,
	Customer_ID VARCHAR(5) REFERENCES Customer(Customer_ID) NOT NULL,
	Purchase_Date DATE NOT NULL,
	Payment_Method VARCHAR(20) NOT NULL
	--Total_Price DECIMAL(10,2) --Created using FUNCTION
)

INSERT INTO Customer_Purchase VALUES('CP01','C01','2016-1-12','Cash On Delivery')
INSERT INTO Customer_Purchase VALUES('CP02','C02','2016-2-20','Cash On Delivery')
INSERT INTO Customer_Purchase VALUES('CP03','C04','2016-6-5','Credit/Debit Card')
INSERT INTO Customer_Purchase VALUES('CP04','C04','2016-8-10','Bank Transfer')
INSERT INTO Customer_Purchase VALUES('CP05','C05','2016-10-30','Online Banking')
INSERT INTO Customer_Purchase VALUES('CP06','C06','2016-10-30','Credit/Debit Card')

GO
CREATE FUNCTION dbo.GetCustomerPurchase_TotalPrice(@id VARCHAR(5))
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @ret DECIMAL(10,2)
	SELECT @ret = SUM(PD.Quantity * B.Selling_Price)
	FROM Book B
	INNER JOIN Purchase_Details PD
		ON B.Book_ID = PD.Book_ID
	INNER JOIN Customer_Purchase CP
		ON PD.Purchase_ID = CP.Purchase_ID 
	WHERE CP.Purchase_ID = @id

	 IF (@ret IS NULL)
		SET @ret = 0
	RETURN @ret
END
GO

ALTER TABLE Customer_Purchase
ADD Total_Price AS dbo.GetCustomerPurchase_TotalPrice(Purchase_ID)

SELECT Purchase_ID,Customer_ID,Purchase_Date,Payment_Method,FORMAT(Total_Price,'c','ms-MY') AS Total_Price FROM Customer_Purchase

---------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE Purchase_Details -- Customer's books purchased details
(
	Purchase_ID VARCHAR(5) REFERENCES Customer_Purchase(Purchase_ID) NOT NULL,
	Book_ID VARCHAR(5) REFERENCES Book(Book_ID) NOT NULL,
	PRIMARY KEY(Purchase_ID,Book_ID),
	Quantity INT NOT NULL,
	Shipment_Status VARCHAR(10) NOT NULL
)

INSERT INTO Purchase_Details VALUES('CP01','B01',1,'Delivered')
INSERT INTO Purchase_Details VALUES('CP01','B02',1,'Delivered')
INSERT INTO Purchase_Details VALUES('CP02','B01',2,'Delivered')
INSERT INTO Purchase_Details VALUES('CP02','B03',1,'Delivered')
INSERT INTO Purchase_Details VALUES('CP03','B06',2,'Delivered')
INSERT INTO Purchase_Details VALUES('CP04','B08',1,'Delivered')
INSERT INTO Purchase_Details VALUES('CP04','B09',1,'Delivered')
INSERT INTO Purchase_Details VALUES('CP05','B02',1,'Shipping')
INSERT INTO Purchase_Details VALUES('CP05','B03',1,'Shipping')
INSERT INTO Purchase_Details VALUES('CP05','B05',1,'Shipping')
INSERT INTO Purchase_Details VALUES('CP06','B12',1,'Delivered')

SELECT * FROM Purchase_Details

---------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE Customer_Feedback
(
	Feedback_ID VARCHAR(5) PRIMARY KEY NOT NULL,
	Purchase_ID VARCHAR(5) REFERENCES Customer_Purchase(Purchase_ID) NOT NULL,
	Book_ID VARCHAR(5) REFERENCES Book(Book_ID) NOT NULL,
	Delivered_Date DATE NOT NULL,
	Feedback_Date DATE NOT NULL,
	Rating VARCHAR(2) NOT NULL,
	Comment VARCHAR(50) NOT NULL
)

INSERT INTO Customer_Feedback VALUES('F01','CP01','B01','2016-1-17','2016-1-19',5,'It''s okay.')
INSERT INTO Customer_Feedback VALUES('F02','CP01','B02','2016-1-17','2016-1-19',5,'It''s okay.')
INSERT INTO Customer_Feedback VALUES('F03','CP02','B01','2016-2-28','2016-3-2',3,'The shipment is slow.')
INSERT INTO Customer_Feedback VALUES('F04','CP02','B01','2016-2-28','2016-3-2',1,'One of the pages in my book is torn!')
INSERT INTO Customer_Feedback VALUES('F05','CP02','B03','2016-2-28','2016-3-2',3,'Bad packaging!')
INSERT INTO Customer_Feedback VALUES('F06','CP03','B06','2016-6-5','2016-6-10',8,'I love it, thank you!')
INSERT INTO Customer_Feedback VALUES('F07','CP03','B06','2016-6-5','2016-6-10',8,'The book is awesome!')
INSERT INTO Customer_Feedback VALUES('F08','CP04','B08','2016-8-16','2016-8-17',9,'Packaging is perfect, satisfied!')
INSERT INTO Customer_Feedback VALUES('F09','CP04','B09','2016-8-16','2016-8-17',9,'Like it so much! Highly recommended.')
INSERT INTO Customer_Feedback VALUES('F10','CP06','B12','2016-11-2','2016-11-2',10,'Shipping is SUPER FAST!')

SELECT * FROM Customer_Feedback

---------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT * FROM Publisher
SELECT Book_ID,Publisher_ID,ISBN,Book_Name,Genres,Author_Name,FORMAT(Initial_Price,'c','ms-MY') AS Initial_Price,FORMAT(Selling_Price,'c','ms-MY') AS Selling_Price,Inventory_Quantity,Effective_Date FROM Book
SELECT Invoice_ID,Publisher_ID,Invoice_Date,Payment_Status,FORMAT(Total_Price,'c','ms-MY') AS Total_Price FROM Invoice
SELECT Invoice_Details_ID,Invoice_ID,ISBN,Book_Name,Quantity,FORMAT(Unit_Price,'c','ms-MY') AS Unit_Price,Shipment_Status FROM Invoice_Details
SELECT * FROM Customer
SELECT Customer_Cart_ID,Customer_ID,FORMAT(Total_Price,'c','ms-MY') AS Total_Price FROM Customer_Cart
SELECT * FROM Cart_Details
SELECT Purchase_ID,Customer_ID,Purchase_Date,Payment_Method,FORMAT(Total_Price,'c','ms-MY') AS Total_Price FROM Customer_Purchase
SELECT * FROM Purchase_Details
SELECT * FROM Customer_Feedback

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QUERIES --
---------------------------------------------------------------------------------------------------------------------------------------------------------------

--i. A list of latest book sent by various publishers based on monthly basis. (Descending)

SELECT ID.ISBN, ID.Book_Name, P.First_Name, P.Last_Name, ID.Quantity, ID.Shipment_Status, I.Received_Date
FROM Invoice_Details ID
INNER JOIN Invoice I
	ON ID.Invoice_ID = I.Invoice_ID
INNER JOIN Publisher P
	ON I.Publisher_ID = P.Publisher_ID
WHERE ID.Shipment_Status = 'Delivered'
ORDER BY YEAR(Received_Date) DESC, MONTH(Received_Date) DESC, DAY(Received_Date) DESC

---------------------------------------------------------------------------------------------------------------------------------------------------------------

--ii. A list of books ordered by store manager from various publishers based on monthly basis. (Descending)

SELECT ID.ISBN, ID.Book_Name, P.First_Name, P.Last_Name, ID.Quantity, ID.Shipment_Status, I.Invoice_Date
FROM Invoice_Details ID
INNER JOIN Invoice I
	ON ID.Invoice_ID = I.Invoice_ID
INNER JOIN Publisher P
	ON I.Publisher_ID = P.Publisher_ID
ORDER BY YEAR(Invoice_Date) DESC, MONTH(Invoice_Date) DESC, DAY(Invoice_Date) DESC

---------------------------------------------------------------------------------------------------------------------------------------------------------------

--iii. Produce a record of invoices for various publishers. The invoice consists of invoice number, invoice date, publisher’s names & addresses and total amount to be paid.

SELECT I.Invoice_ID, I.Invoice_Date, P.First_Name, P.Last_Name, P.Company_Name, P.House_No, P.Address_Line1, P.Address_Line2, P.Post_Code, P.City, P.City_State, P.Country, FORMAT(Total_Price,'c','ms-MY') AS Total_Price
FROM Invoice I
INNER JOIN Publisher P
	ON I.Publisher_ID = P.Publisher_ID
WHERE Payment_Status = 'Unpaid'

---------------------------------------------------------------------------------------------------------------------------------------------------------------

--iv. A list of all customer records who are registered members in APU E-Bookstore. The record of each member should show member identification number, first name and last name, address and contact number.  

SELECT C.Customer_ID, C.First_Name, C.Last_Name , C.House_No, C.Address_Line1, C.Address_Line2, C.Post_Code, C.City, C.City_State, C.Country, C.Contact_Number
FROM Customer C

---------------------------------------------------------------------------------------------------------------------------------------------------------------

--v. A list of purchased books that have been delivered to members. The list should show member identification number, first name and last name, address, contact number, book serial number, book title, quantity, date and status of delivery.

SELECT CP.Customer_ID, C.First_Name, C.Last_Name, C.House_No, C.Address_Line1, C.Address_Line2,C.Post_Code, C.City, C.City_State, C.Country, C.Contact_Number, B.Book_ID, B.Book_Name, PD.Quantity, CP.Purchase_Date, PD.Shipment_Status
FROM Purchase_Details PD
INNER JOIN Customer_Purchase CP
	ON PD.Purchase_ID = CP.Purchase_ID 
INNER JOIN Customer C
	ON CP.Customer_ID = C.Customer_ID
INNER JOIN Book B
	ON PD.Book_ID = B.Book_ID
WHERE PD.Shipment_Status = 'Delivered'

---------------------------------------------------------------------------------------------------------------------------------------------------------------

--vi. List of books based on specific categories (e.g. Science Fiction, Romantic, History, Horror, etc.). The list should show type of book category, book serial number, book title and quantity. 

SELECT Genres, Book_ID, Book_Name, Inventory_Quantity
FROM Book
ORDER BY Genres

---------------------------------------------------------------------------------------------------------------------------------------------------------------

--vii. Produce list of total number of books for each category of books.

SELECT Genres, COUNT(*) AS Total_Number_Of_Books
FROM Book
GROUP BY Genres

---------------------------------------------------------------------------------------------------------------------------------------------------------------

--viii. A list of total books and its total price as added by members in shopping cart.

SELECT CD.Customer_Cart_ID, C.First_Name, C.Last_Name, COUNT(CD.Book_ID) AS Total_Books,FORMAT(Total_Price,'c','ms-MY') AS Total_Price
FROM Cart_Details CD
INNER JOIN Customer_Cart CC
	ON CD.Customer_Cart_ID = CC.Customer_Cart_ID
INNER JOIN Customer C
	ON CC.Customer_ID = C.Customer_ID
GROUP BY CD.Customer_Cart_ID, C.First_Name, C.Last_Name, CC.Total_Price

-- viii. Display book title details

SELECT CD.Customer_Cart_ID,C.First_Name, C.Last_Name, B.Book_Name,FORMAT(Total_Price,'c','ms-MY') AS Total_Price
FROM Book B
INNER JOIN Cart_Details CD
	ON B.Book_ID = CD.Book_ID
INNER JOIN Customer_Cart CC
	ON CD.Customer_Cart_ID = CC.Customer_Cart_ID
INNER JOIN Customer C
	ON CC.Customer_ID = C.Customer_ID

---------------------------------------------------------------------------------------------------------------------------------------------------------------

--ix. Produce a list of book with the number of various feedbacks for books based on scores (1-10 which is 0= terrible, 10= masterpiece) rated by members.

SELECT B.Book_ID, B.Book_Name, B.Genres, B.Author_Name, CF.Rating, CF.Comment, C.First_Name, C.Last_Name
FROM Customer C
INNER JOIN Customer_Purchase CP
	ON C.Customer_ID = CP.Customer_ID
INNER JOIN Customer_Feedback CF
	ON CP.Purchase_ID = CF.Purchase_ID
INNER JOIN Book B
	ON CF.Book_ID = B.Book_ID
ORDER BY CF.Rating