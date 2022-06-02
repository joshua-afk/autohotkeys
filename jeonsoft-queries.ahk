#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

::$sqlActivateSecurityKeys::
(
UPDATE tblSecurityKeys SET Active = 1 WHERE SecurityKey IN ('Import.SecurityUsers', 'Import.SecurityGroups', ...)

DECLARE @tmp TABLE(Id INT IDENTITY(1,1), SecurityKeyId INT, ParentId INT)
INSERT INTO @tmp(SecurityKeyId, ParentId)
SELECT sk.Id, sk.ParentId
FROM tblSecurityKeys sk
WHERE sk.SecurityKey IN ('Import.SecurityUsers', 'Import.SecurityGroups', ...)

DECLARE @ParentSecurityKeyId INT
DECLARE @NewSecurityKeyId INT

DECLARE cur1 CURSOR FOR
	SELECT t.SecurityKeyId, t.ParentId
	FROM @tmp t
	ORDER BY t.Id

OPEN cur1
FETCH NEXT FROM cur1 INTO @NewSecurityKeyId, @ParentSecurityKeyId

WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO tblSecurityGroupSecurityKeys(SecurityGroupId, SecurityKeyId)
	SELECT sgsk.SecurityGroupId, @NewSecurityKeyId
	FROM tblSecurityGroupSecurityKeys sgsk
	WHERE sgsk.SecurityKeyId = @ParentSecurityKeyId
		AND NOT EXISTS(SELECT * FROM tblSecurityGroupSecurityKeys xsgsk WHERE xsgsk.SecurityGroupId = sgsk.SecurityGroupId AND xsgsk.SecurityKeyId = @NewSecurityKeyId)

	INSERT INTO tblSecurityUserSecurityKeys(SecurityUserId, SecurityKeyId)
	SELECT susk.SecurityUserId, @NewSecurityKeyId
	FROM tblSecurityUserSecurityKeys susk
	WHERE susk.SecurityKeyId = @ParentSecurityKeyId
		AND NOT EXISTS(SELECT * FROM tblSecurityUserSecurityKeys xsusk WHERE xsusk.SecurityUserId = susk.SecurityUserId AND xsusk.SecurityKeyId = @NewSecurityKeyId)

	FETCH NEXT FROM cur1 INTO @NewSecurityKeyId, @ParentSecurityKeyId
END

CLOSE cur1
DEALLOCATE cur1

GO
)
return

::$createsecuritykey::
(
DECLARE @ParentSecurityKeyId INT
DECLARE @NewSecurityKeyId INT

EXEC uspPostSecurityKey 'PayGroupSettings.Preferences', 'Custom Pay Group Settings Preferences', 'Custom.PayGroupSettings', 4
SELECT @NewSecurityKeyId = Id FROM tblSecurityKeys WHERE SecurityKey = 'PayGroupSettings.Preferences'
SELECT @ParentSecurityKeyId = Id FROM tblSecurityKeys WHERE SecurityKey = 'Custom.PayGroupSettings'

INSERT INTO tblSecurityGroupSecurityKeys(SecurityGroupId, SecurityKeyId)
SELECT sgsk.SecurityGroupId, @NewSecurityKeyId
FROM tblSecurityGroupSecurityKeys sgsk
WHERE sgsk.SecurityKeyId = @ParentSecurityKeyId
    AND NOT EXISTS(SELECT * FROM tblSecurityGroupSecurityKeys xsgsk WHERE xsgsk.SecurityGroupId = sgsk.SecurityGroupId AND xsgsk.SecurityKeyId = @NewSecurityKeyId)
INSERT INTO tblSecurityUserSecurityKeys(SecurityUserId, SecurityKeyId)
SELECT susk.SecurityUserId, @NewSecurityKeyId
FROM tblSecurityUserSecurityKeys susk
WHERE susk.SecurityKeyId = @ParentSecurityKeyId
    AND NOT EXISTS(SELECT * FROM tblSecurityUserSecurityKeys xsusk WHERE xsusk.SecurityUserId = susk.SecurityUserId AND xsusk.SecurityKeyId = @NewSecurityKeyId)

EXEC uspUpdateSecurityKeyOrder
GO

--UPDATE tblSecurityKeys SET Checksum = '1998418902' WHERE SecurityKey = 'PayGroupSettings.Preferences'
)
return

::$getchecksum::
(
DECLARE @IsCheck BIT
DECLARE @IsUpdate BIT
DECLARE @PrivateKey VARCHAR(50)

SET @IsUpdate = 0
SET @IsCheck = 1
SET @PrivateKey = '9710265'

IF @IsCheck = 1
BEGIN
	SELECT ABS(BINARY_CHECKSUM(sk.SecurityKey + ed.Name + @PrivateKey)), sk.*, pk.SecurityKey AS ParentKey
	FROM tblSecurityKeys sk INNER JOIN
		tblEditions ed ON sk.EditionId = ed.Id LEFT OUTER JOIN
		tblSecurityKeys pk ON sk.ParentId = pk.Id
	WHERE ISNULL(sk.[CheckSum], 0) <> ISNULL(ABS(BINARY_CHECKSUM(sk.SecurityKey + ed.Name + @PrivateKey)), 0)
	
	RETURN
END

IF @IsUpdate = 1 
BEGIN
	UPDATE sk
	SET [CheckSum] = ABS(BINARY_CHECKSUM(sk.SecurityKey + ed.Name + @PrivateKey)) 
	FROM tblSecurityKeys sk INNER JOIN
		tblEditions ed ON sk.EditionId = ed.Id 
	WHERE ISNULL([CheckSum], 0) <> ISNULL(ABS(BINARY_CHECKSUM(sk.SecurityKey + ed.Name + @PrivateKey)), 0)
END

IF @IsUpdate = 0 
BEGIN
	DECLARE @SecurityKey VARCHAR(100)
	DECLARE @Edition VARCHAR(50)

	SET @SecurityKey = 'Transfer.Post'
	SET @Edition = 'Payroll Premium'

	SELECT ABS(BINARY_CHECKSUM(@SecurityKey + @Edition + @PrivateKey)) 
END
GO
)
return

::$jsreset::
(
IF OBJECT_ID('tblSecurityUsers') IS NOT NULL
BEGIN
	UPDATE tblSecurityUsers
	SET PasswordHash = 398963028,
	 WebJPSPDFReportPassword = 'AXfkjk qtttO'
END
--Enable Sub Module for report explorer/designer
IF OBJECT_ID('tblSubModuleButtons') IS NOT NULL
BEGIN
	UPDATE tblSubModuleButtons
	SET IsEnable = 1
END
UPDATE tblEmployees SET EmailAddress = NULL
UPDATE tblSecurityUsers SET EmailAddress = NULL

UPDATE tblEmployees SET EmployeePassword = '6E56CC2DD310EEBE1C9B2345D3682A3829DE80AACEE789C8BFAB7F998D24E2DD'
)
return

::$updatecustomport::
(
UPDATE tblPPHCustomizationAssetsServers
SET ServerName = 'http://localhost:7777'

UPDATE tblPPHCustomizationServers
SET ServerName = 'http://localhost:7777'
)
return
