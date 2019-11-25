-- MySQL dump 10.13  Distrib 8.0.18, for macos10.14 (x86_64)
--
-- Host: localhost    Database: CS5200
-- ------------------------------------------------------
-- Server version	8.0.17

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Customer`
--

DROP TABLE IF EXISTS `Customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Customer` (
  `CustomerID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Address` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `City` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `State` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `Country` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Postal` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`CustomerID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Inventory`
--

DROP TABLE IF EXISTS `Inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Inventory` (
  `InventoryID` int(11) NOT NULL AUTO_INCREMENT,
  `SKU` varchar(12) NOT NULL,
  `Quantity` int(11) NOT NULL,
  `updatedDate` date DEFAULT NULL,
  PRIMARY KEY (`InventoryID`),
  KEY `inventory_ibfk_1` (`SKU`),
  CONSTRAINT `inventory_ibfk_1` FOREIGN KEY (`SKU`) REFERENCES `products` (`SKU`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `OrderRecord`
--

DROP TABLE IF EXISTS `OrderRecord`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `OrderRecord` (
  `OrderID` int(11) NOT NULL,
  `SKU` varchar(12) NOT NULL,
  `Quantity` int(11) NOT NULL,
  `Price` decimal(10,2) NOT NULL,
  `ShipDate` date DEFAULT NULL,
  `Status` varchar(32) DEFAULT NULL,
  `BackOrder` tinyint(1) NOT NULL,
  KEY `orderrecord_ibfk_2` (`OrderID`),
  KEY `orderrecord_ibfk_3` (`SKU`),
  CONSTRAINT `orderrecord_ibfk_2` FOREIGN KEY (`OrderID`) REFERENCES `orders` (`OrderID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `orderrecord_ibfk_3` FOREIGN KEY (`SKU`) REFERENCES `products` (`SKU`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `InventoryUpdate` BEFORE INSERT ON `orderrecord` FOR EACH ROW BEGIN
SET @PrevBackOrder:= (SELECT MIN(OrderID) FROM OrderRecord WHERE BackOrder = 1 AND SKU = NEW.SKU);
IF (@PrevBackOrder IS NULL) THEN
	UPDATE Inventory SET Quantity = Quantity - NEW.Quantity WHERE SKU = NEW.SKU;
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `PriceUpdate` BEFORE UPDATE ON `orderrecord` FOR EACH ROW BEGIN 
SET @NewPrice:= (SELECT Price FROM PriceHistory WHERE fromDate IN (SELECT MAX(fromDate) FROM PriceHistory WHERE SKU = NEW.SKU) AND SKU = NEW.SKU);
SET @CustomerID:= (SELECT CustomerID FROM Orders WHERE OrderID = NEW.OrderID);
IF (NEW.Price > @NewPrice) THEN
	SET @Amount = (NEW.Price - @NewPrice) * NEW.Quantity;
    INSERT INTO Reimbursement(CustomerID, OrderID, Amount) VALUES (@CustomerID, NEW.OrderID, @Amount);
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `OrderCancel` BEFORE DELETE ON `orderrecord` FOR EACH ROW DELETE FROM Orders WHERE OrderID NOT IN (SELECT OrderID FROM OrderRecord) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Orders`
--

DROP TABLE IF EXISTS `Orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Orders` (
  `OrderID` int(11) NOT NULL AUTO_INCREMENT,
  `CustomerID` int(11) NOT NULL,
  `OrderDate` date NOT NULL,
  `Partially` tinyint(1) NOT NULL,
  PRIMARY KEY (`OrderID`),
  KEY `orders_ibfk_1` (`CustomerID`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`CustomerID`) REFERENCES `customer` (`CustomerID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `PriceHistory`
--

DROP TABLE IF EXISTS `PriceHistory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `PriceHistory` (
  `PriceID` int(11) NOT NULL AUTO_INCREMENT,
  `SKU` varchar(12) NOT NULL,
  `Price` int(11) NOT NULL,
  `fromDate` date NOT NULL,
  `toDate` date DEFAULT NULL,
  PRIMARY KEY (`PriceID`),
  KEY `SKU` (`SKU`),
  CONSTRAINT `pricehistory_ibfk_1` FOREIGN KEY (`SKU`) REFERENCES `products` (`SKU`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Products`
--

DROP TABLE IF EXISTS `Products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Products` (
  `SKU` varchar(12) NOT NULL,
  `Name` varchar(64) NOT NULL,
  `Description` text NOT NULL,
  `Price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`SKU`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Reimbursement`
--

DROP TABLE IF EXISTS `Reimbursement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Reimbursement` (
  `ReimburseID` int(11) NOT NULL AUTO_INCREMENT,
  `CustomerID` int(11) NOT NULL,
  `OrderID` int(11) NOT NULL,
  `Amount` decimal(10,2) NOT NULL,
  PRIMARY KEY (`ReimburseID`),
  KEY `CustomerID` (`CustomerID`),
  KEY `OrderID` (`OrderID`),
  CONSTRAINT `reimbursement_ibfk_1` FOREIGN KEY (`CustomerID`) REFERENCES `orders` (`CustomerID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reimbursement_ibfk_2` FOREIGN KEY (`OrderID`) REFERENCES `orders` (`OrderID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'CS5200'
--
/*!50003 DROP PROCEDURE IF EXISTS `CustomerInfo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CustomerInfo`(IN CustomerIDInput INT)
    READS SQL DATA
BEGIN 
	SELECT * FROM Customer WHERE CustomerID = CustomerIDInput;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CustomerOrder` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CustomerOrder`(IN `CustomerIDInput` INT)
    READS SQL DATA
SELECT Name, Quantity, Price, Total, OrderDate, ShipDate, Status FROM
(
SELECT 1 AS ord, CustomerID, a.OrderID, c.Name, Quantity, a.Price, Quantity * a.Price AS Total, OrderDate, ShipDate, Status 
FROM OrderRecord a 
INNER JOIN Orders b ON a.OrderID = b.OrderID 
INNER JOIN Products c ON a.SKU = c.SKU 
WHERE CustomerID = CustomerIDInput
UNION
SELECT 2 AS ord, CustomerID, OrderID, "Reimburse", "", "", SUM(Amount) * -1 AS Total, "", "", ""
FROM Reimbursement c
WHERE CustomerID = CustomerIDInput
GROUP BY OrderID
UNION
SELECT 4 AS ord, CustomerID, a.OrderID, "Total Charge", "", "", SUM(Total) AS Total, "", "", ""
FROM (
    SELECT CustomerID, a.OrderID, SUM(Quantity * a.Price) AS Total
    FROM OrderRecord a
    INNER JOIN Orders b ON a.OrderID = b.OrderID
    INNER JOIN Products c ON a.SKU = c.SKU
    WHERE CustomerID = CustomerIDInput
    GROUP BY a.OrderID 
    UNION
    SELECT a.CustomerID, a.OrderID, SUM(IFNULL(Amount, 0)) * -1 AS Total
    FROM Orders a 
    LEFT JOIN Reimbursement c ON a.OrderID = c.OrderID
    WHERE a.CustomerID = CustomerIDInput
    GROUP BY a.OrderID
) a
WHERE CustomerID = CustomerIDInput
GROUP BY OrderID
ORDER BY OrderID
) b 
ORDER BY OrderID, ord ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InsertCustomer` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertCustomer`(IN `NameInput` VARCHAR(32), IN `AddressInput` VARCHAR(64), IN `CityInput` VARCHAR(32), IN `StateInput` VARCHAR(2), IN `CountryInput` VARCHAR(32), IN `PostalInput` VARCHAR(16))
    MODIFIES SQL DATA
BEGIN
CALL validateCustomerName(NameInput);
CALL validateCustomerAddress(AddressInput);
CALL validateCustomerCity(CityInput);
CALL validateCustomerState(StateInput);
CALL validateCustomerCountry(CountryInput);
CALL validateCustomerPostal(PostalInput);

INSERT INTO Customer(Name, Address, City, State, Country, Postal) VALUES (NameInput, AddressInput, CityInput, StateInput, CountryInput, PostalInput);
SELECT * FROM Customer Order By CustomerID DESC LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InsertInventory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertInventory`(IN `SKUInput` VARCHAR(12), IN `QuantityInput` INT, IN `DateInput` DATE)
    MODIFIES SQL DATA
BEGIN
DECLARE SKU1 VARCHAR(12);
DECLARE InventoryID1 INT;
DECLARE PrevQuantity INT;
DECLARE UpdatedQuantity INT;
DECLARE OldestBackOrderQuant INT;

START TRANSACTION;
CALL validateSKU(SKUInput);
CALL validateQuantity(QuantityInput);

SELECT IFNULL(MAX(InventoryID),0) + 1 AS ID INTO InventoryID1 FROM Inventory;
IF (SELECT COUNT(*) FROM Inventory WHERE SKU = SKUInput) = 0 THEN
	IF NOT EXISTS (SELECT * FROM Products WHERE SKU = SKUInput) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Product does not exist';
    ELSE
		INSERT INTO Inventory(InventoryID, SKU, Quantity, updatedDate) VALUES (InventoryID1, SKUInput, QuantityInput, DateInput);
        SET OldestBackOrderQuant = (SELECT Quantity FROM OrderRecord WHERE OrderID IN (SELECT MIN(OrderID) AS OrderID FROM OrderRecord WHERE SKU = SKUInput AND BackOrder = 1) AND  SKU = SKUInput AND BackOrder = 1);
        SET UpdatedQuantity = (SELECT Quantity FROM Inventory WHERE SKU = SKUInput);
        WHILE (UpdatedQuantity >= OldestBackOrderQuant) DO
            UPDATE OrderRecord SET BackOrder = 0, ShipDate = DATE_ADD(DateInput, INTERVAL 1 DAY), Status = "Ready to ship" WHERE OrderID IN (SELECT * FROM (SELECT MIN(OrderID) AS OrderID FROM OrderRecord WHERE SKU = SKUInput AND BackOrder = 1) AS tblTmp) AND SKU = SKUInput AND BackOrder = 1;
            UPDATE Inventory SET Quantity = Quantity - OldestBackOrderQuant WHERE SKU = SKUInput;
            SET OldestBackOrderQuant = (SELECT Quantity FROM OrderRecord WHERE OrderID IN (SELECT MIN(OrderID) AS OrderID FROM OrderRecord WHERE SKU = SKUInput AND BackOrder = 1) AND SKU = SKUInput AND BackOrder = 1);
            SET UpdatedQuantity = (SELECT Quantity FROM Inventory WHERE SKU = SKUInput);
        END WHILE;
    END IF;
ELSE 
    IF NOT EXISTS (SELECT * FROM Products WHERE SKU = SKUInput) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Product does not exist';
    ELSE
        SELECT SKU INTO SKU1 FROM Inventory WHERE SKU = SKUInput;
        SELECT Quantity INTO PrevQuantity FROM Inventory WHERE SKU = SKUInput;
        IF (SKU1 IS NOT NULL) THEN
			UPDATE Inventory SET Quantity = QuantityInput + PrevQuantity, updatedDate = DateInput WHERE SKU = SKU1;
        ELSE
            INSERT INTO Inventory(InventoryID, SKU, Quantity, updatedDate) VALUES (InventoryID1, SKUInput, QuantityInput + PrevQuantity, DateInput);
        END IF;
        SET OldestBackOrderQuant = (SELECT Quantity FROM OrderRecord WHERE OrderID IN (SELECT MIN(OrderID) AS OrderID FROM OrderRecord WHERE SKU = SKUInput AND BackOrder = 1) AND  SKU = SKUInput AND BackOrder = 1);
        SET UpdatedQuantity = (SELECT Quantity FROM Inventory WHERE SKU = SKUInput);
        WHILE (UpdatedQuantity >= OldestBackOrderQuant) DO
            UPDATE OrderRecord SET BackOrder = 0, ShipDate = DATE_ADD(DateInput, INTERVAL 1 DAY), Status = "Ready to ship" WHERE OrderID IN (SELECT * FROM (SELECT MIN(OrderID) AS OrderID FROM OrderRecord WHERE SKU = SKUInput AND BackOrder = 1) AS tblTmp) AND SKU = SKUInput AND BackOrder = 1;
            UPDATE Inventory SET Quantity = Quantity - OldestBackOrderQuant WHERE SKU = SKUInput;
            SET OldestBackOrderQuant = (SELECT Quantity FROM OrderRecord WHERE OrderID IN (SELECT MIN(OrderID) AS OrderID FROM OrderRecord WHERE SKU = SKUInput AND BackOrder = 1) AND SKU = SKUInput AND BackOrder = 1);
            SET UpdatedQuantity = (SELECT Quantity FROM Inventory WHERE SKU = SKUInput);
        END WHILE;

    END IF;
END IF;
COMMIT;

SELECT SKU, Quantity, updatedDate FROM Inventory ORDER BY SKU;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InsertOrder` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertOrder`(IN `CustomerIDInput` INT, IN `OrderDateInput` DATE, IN `PartiallyInput` BOOLEAN, IN `SKUList` TEXT, IN `QuantityList` TEXT)
    MODIFIES SQL DATA
BEGIN
DECLARE OrderID1 INT;
DECLARE SKULen INT DEFAULT 0;
DECLARE SubSKULen INT DEFAULT 0;
DECLARE QuantityLen INT DEFAULT 0;
DECLARE SubQuantityLen INT DEFAULT 0;
DECLARE SKULen1 INT DEFAULT 0;
DECLARE SubSKULen1 INT DEFAULT 0;
DECLARE QuantityLen1 INT DEFAULT 0;
DECLARE SubQuantityLen1 INT DEFAULT 0;
DECLARE SKUList1 TEXT;
DECLARE QuantityList1 TEXT;

SET SKUList1 = SKUList;
SET QuantityList1 = QuantityList;

BEGIN
	ROLLBACK;
END;

START TRANSACTION;
validate_list:
	LOOP
		SET SKULen1 = CHAR_LENGTH(SKUList1);
		SET QuantityLen1 = CHAR_LENGTH(QuantityList1);

		CALL validateSKU(TRIM(SUBSTRING_INDEX(SKUList1, ',', 1)));
		CALL validateQuantity(TRIM(SUBSTRING_INDEX(QuantityList1, ',', 1)));

		SET SubSKULen1 = CHAR_LENGTH(SUBSTRING_INDEX(SKUList1, ',', 1)) + 2;
		SET SKUList1 = MID(SKUList1, SubSKULen1, SKULen1);

		SET SubQuantityLen1 = CHAR_LENGTH(TRIM(SUBSTRING_INDEX(QuantityList1, ',', 1))) + 2;
		SET QuantityList1 = TRIM(MID(QuantityList1, SubQuantityLen1, QuantityLen1));
		IF QuantityList1 = '' THEN
			LEAVE validate_list;
		END IF;
	END LOOP;

SELECT IFNULL(MAX(OrderID),0) + 1 AS ID INTO OrderID1 FROM Orders;
INSERT INTO Orders(OrderID, CustomerID, OrderDate, Partially) VALUES(OrderID1, CustomerIDInput, OrderDateInput, PartiallyInput);

BEGIN
IF SKUList IS NULL THEN
	SET SKUList = '';
END IF;

insert_list:
    LOOP
        SET SKULen = CHAR_LENGTH(SKUList);
        SET QuantityLen = CHAR_LENGTH(QuantityList);

        CALL InsertOrderRecord (OrderID1, TRIM(SUBSTRING_INDEX(SKUList, ',', 1)), TRIM(SUBSTRING_INDEX(QuantityList, ',', 1)), OrderDateInput, PartiallyInput);

        SET SubSKULen = CHAR_LENGTH(SUBSTRING_INDEX(SKUList, ',', 1)) + 2;
        SET SKUList = MID(SKUList, SubSKULen, SKULen);

        SET SubQuantityLen = CHAR_LENGTH(TRIM(SUBSTRING_INDEX(QuantityList, ',', 1))) + 2;
        SET QuantityList = TRIM(MID(QuantityList, SubQuantityLen, QuantityLen));
        IF QuantityList = '' THEN
            LEAVE insert_list;
        END IF;
    END LOOP;
END;
COMMIT;
CALL CustomerOrder(CustomerIDInput);
CALL InventoryDisplay();
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InsertOrderRecord` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertOrderRecord`(IN `OrderID1` INT, IN `SKUInput` VARCHAR(12), IN `QuantityInput` INT, IN `OrderDate` DATE, IN `Part` BOOLEAN)
    MODIFIES SQL DATA
BEGIN
DECLARE InventoryID1 INT;
DECLARE Price1 DECIMAL(10,2);
DECLARE InventoryQuantity1 INT;
DECLARE PrevBackOrder INT;
DECLARE InventoryDate DATE;
DECLARE ResetPoint INT;

START TRANSACTION;
SELECT InventoryID INTO InventoryID1 FROM Inventory WHERE SKU = SKUInput;
SELECT Price INTO Price1 FROM PriceHistory WHERE SKU = SKUInput AND OrderDate BETWEEN fromDate AND IFNULL(toDate,'9999-12-31');
SELECT MIN(OrderID) INTO PrevBackOrder FROM OrderRecord WHERE BackOrder = 1 AND SKU = SKUInput;
SELECT updatedDate INTO InventoryDate FROM Inventory WHERE SKU = SKUInput;
SELECT Quantity INTO InventoryQuantity1 FROM Inventory WHERE SKU = SKUInput;

IF NOT EXISTS (SELECT * FROM Products WHERE SKU = SKUInput) THEN
		DELETE FROM Orders WHERE OrderID NOT IN (SELECT OrderID FROM OrderRecord);
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Product does not exist';
ELSE
	IF (PrevBackOrder IS NOT NULL) THEN
		INSERT INTO OrderRecord(OrderID, SKU, Quantity, Price, ShipDate, Status, BackOrder) VALUES (OrderID1, SKUInput, QuantityInput, Price1, NULL, "In Process", 1);
	ELSE 
		IF Part = 1 THEN
			IF QuantityInput <= InventoryQuantity1 THEN
				INSERT INTO OrderRecord(OrderID, SKU, Quantity, Price, ShipDate, Status, BackOrder) VALUES (OrderID1, SKUInput, QuantityInput, Price1, DATE_ADD(IF (OrderDate > InventoryDate, OrderDate, InventoryDate), INTERVAL 1 DAY), "Ready to ship", 0);
			 ELSE
				IF (InventoryQuantity1 != 0) THEN
					INSERT INTO OrderRecord(OrderID, SKU, Quantity, Price, ShipDate, Status, BackOrder) VALUES (OrderID1, SKUInput, InventoryQuantity1, Price1, DATE_ADD(IF (OrderDate > InventoryDate, OrderDate, InventoryDate), INTERVAL 1 DAY), "Ready to ship", 0), (OrderID1, SKUInput, QuantityInput - InventoryQuantity1, Price1, NULL, "In Process", 1);
					UPDATE Inventory SET Quantity = 0 WHERE SKU = SKUInput;
				ELSE
					INSERT INTO OrderRecord(OrderID, SKU, Quantity, Price, ShipDate, Status, BackOrder) VALUES (OrderID1, SKUInput, QuantityInput - InventoryQuantity1, Price1, NULL, "In Process", 1);
					UPDATE Inventory SET Quantity = 0 WHERE SKU = SKUInput;
				END IF;
			 END IF;
		ELSE
			IF QuantityInput <= InventoryQuantity1 THEN
				INSERT INTO OrderRecord(OrderID, SKU, Quantity, Price, ShipDate, Status, BackOrder) VALUES (OrderID1, SKUInput, QuantityInput, Price1,DATE_ADD(IF (OrderDate > InventoryDate, OrderDate, InventoryDate), INTERVAL 1 DAY), "Ready to ship", 0);
			ELSE
				INSERT INTO OrderRecord(OrderID, SKU, Quantity, Price, ShipDate, Status, BackOrder) VALUES (OrderID1, SKUInput, QuantityInput, Price1, NULL, "In Process", 1);
				UPDATE Inventory SET Quantity = 0 WHERE SKU = SKUInput;
			END IF;
		END IF;
	END IF;
END IF;
COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InsertPrice` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertPrice`(IN `SKUInput` VARCHAR(12), IN `PriceInput` DECIMAL(10,2), IN `fromDateInput` DATE)
    MODIFIES SQL DATA
BEGIN
DECLARE maxPriceID INT;
SELECT MAX(PriceID) INTO maxPriceID FROM PriceHistory WHERE SKU = SKUInput;

CALL validateSKU(SKUInput);
CALL validatePrice(PriceInput);

IF (SELECT COUNT(*) FROM PriceHistory WHERE SKU = SKUInput) = 0 THEN
	IF NOT EXISTS (SELECT * FROM Products WHERE SKU = SKUInput) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Product does not exist';
    ELSE
        INSERT INTO PriceHistory (SKU, Price, fromDate) VALUES (SKUInput, PriceInput, fromDateInput);
        UPDATE Products SET Price = PriceInput WHERE SKU = SKUInput;
	END IF;
ELSE
	IF NOT EXISTS (SELECT * FROM Products WHERE SKU = SKUInput) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Product does not exist';
    ELSE
        UPDATE PriceHistory SET toDate = DATE_SUB(fromDateInput, INTERVAL 1 DAY) WHERE PriceID = maxPriceID;
        INSERT INTO PriceHistory (SKU, Price, fromDate) VALUES (SKUInput, PriceInput, fromDateInput);
        UPDATE Products SET Price = PriceInput WHERE SKU = SKUInput;
	END IF;
END IF;
SELECT * FROM PriceHistory;
CALL ProductInfo(SKUInput);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InsertProduct` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertProduct`(IN `SKUInput` VARCHAR(12), IN `NameInput` VARCHAR(64), IN `DescriptionInput` TEXT, IN `PriceInput` DECIMAL(10,2), IN `DateInput` DATE)
    MODIFIES SQL DATA
BEGIN
CALL validateSKU(SKUInput);
CALL validatePrice(PriceInput);

IF EXISTS (SELECT * FROM Products WHERE SKU = SKUInput) THEN
	SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT = 'Product already exists';
ELSE
    INSERT INTO Products(SKU, Name, Description, Price) VALUES (SKUInput, NameInput, DescriptionInput, PriceInput);
    INSERT INTO PriceHistory(SKU, Price, fromDate) VALUES (SKUInput, PriceInput, DateInput);
END IF;
SELECT * FROM Products;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InventoryDisplay` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `InventoryDisplay`()
    READS SQL DATA
BEGIN 
	SELECT SKU, Quantity, updatedDate FROM Inventory ORDER BY SKU;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ProductInfo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `ProductInfo`(IN `SKUInput` VARCHAR(12))
    READS SQL DATA
BEGIN
CALL validateSKU(SKUInput);

IF NOT EXISTS (SELECT * FROM Products WHERE SKU = SKUInput) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Product does not exist';
ELSE
	SELECT * FROM Products WHERE SKU = SKUInput
	UNION
	SELECT 'Recommended Products', GROUP_CONCAT(Name SEPARATOR ', ') AS Recommendation, '', '' FROM Products WHERE SKU IN (SELECT * FROM (
	SELECT SKU FROM OrderRecord WHERE (
		SELECT COUNT(SKU)
		FROM OrderRecord 
		WHERE OrderID IN (SELECT OrderID 
					  FROM OrderRecord WHERE SKU = SKUInput GROUP BY OrderID) 
					  AND SKU NOT IN (SKUInput)
		) >= 1 AND SKU NOT IN (SKUInput)
		GROUP BY SKU
		ORDER BY COUNT(SKU) DESC 
		LIMIT 3) as t);
END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `validateCustomerAddress` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `validateCustomerAddress`(IN `address` VARCHAR(64))
    READS SQL DATA
    DETERMINISTIC
BEGIN

IF NOT address REGEXP '[:alnum:]' THEN

	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid address';
    
END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `validateCustomerCity` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `validateCustomerCity`(IN `City` VARCHAR(32))
    READS SQL DATA
    DETERMINISTIC
BEGIN

IF NOT City REGEXP '[a-zA-Z]' THEN

	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid city name';
    
END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `validateCustomerCountry` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `validateCustomerCountry`(IN `Country` VARCHAR(32))
    READS SQL DATA
    DETERMINISTIC
BEGIN

IF NOT Country REGEXP '[a-zA-Z]' THEN

	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid country';
    
END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `validateCustomerName` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `validateCustomerName`(IN `Name` VARCHAR(32))
    READS SQL DATA
    DETERMINISTIC
BEGIN

IF NOT Name REGEXP '[a-zA-Z]' THEN

	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid Name';
    
END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `validateCustomerPostal` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `validateCustomerPostal`(IN `Postal` INT)
    READS SQL DATA
    DETERMINISTIC
BEGIN

IF NOT Postal REGEXP '^[0-9]+$' AND Postal < 0 THEN

	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid Postal';
    
END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `validateCustomerState` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `validateCustomerState`(IN `State` VARCHAR(2))
    READS SQL DATA
    DETERMINISTIC
BEGIN

IF NOT State REGEXP '^[a-zA-Z]+$' THEN

	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid state';
    
END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `validatePrice` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `validatePrice`(IN `Price` DECIMAL(10,2))
    READS SQL DATA
    DETERMINISTIC
BEGIN

IF Price < 0 THEN

	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid Price';
    
END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `validateQuantity` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `validateQuantity`(IN `Quantity` INT)
    READS SQL DATA
    DETERMINISTIC
BEGIN

IF Quantity < 0 THEN

	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid Quantity';
    
END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `validateSKU` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `validateSKU`(IN `SKU` VARCHAR(12))
    READS SQL DATA
    DETERMINISTIC
BEGIN

IF NOT BINARY SKU REGEXP '^[A-Z][A-Z]-[0-9][0-9][0-9][0-9][0-9][0-9]-[A-Z0-9][A-Z0-9]$' THEN

	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid SKU';
    
END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-11-24 21:04:50
