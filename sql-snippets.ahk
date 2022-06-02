#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; This is a hotstring, space is not needed to trigger the script
:*:$sqlsel::SELECT * FROM tbl

::$sqlwhere::
(
SELECT *
FROM table_name
WHERE columnName = 0
)
return

::$sqlinsert::
(
INSERT INTO table_name (column1, column2, column3, ...)
VALUES (value1, value2, value3, ...)
)
return

::$sqlupdate::
(
UPDATE table_name
SET column1 = value1, column2 = value2, ...
WHERE condition
)
return

::$sqlmassupdate::
(
UPDATE table_name
SET column1 = value1, column2 = value2, ...
WHERE Id IN (id1, id2, ...)
)
return

:*:$sqldel::DELETE FROM table_name WHERE condition

::$sqllike::
(
SELECT *
FROM table_name
WHERE columnName LIKE '%or%'
)
return


::$sqladdcol::
(
ALTER TABLE tblCustomers
ADD Email varchar(255) NULL;
)
return
