# db2xml

A simple tool to test performance on a typical table in Temenos banking software.

https://stackoverflow.com/questions/51869740/temenos-t24-database-structure

DB2 specific: https://blog.4loeser.net/2013/06/some-typical-db2-registry-settings-for.html

A typical table schema is as follows :
<br>
> CREATE TABLE XMLID (RECID VARCHAR(100) PRIMARY KEY NO NULL, XMLRECORD XMLTYPE)

In Temenos software, relational database is simply a container for xml files. Typical database can contain up to 50000 (fifty thousand) tables.
<br>
There are different options of column type used to keep XML data.<br>
* XMLTYPE (Oracle), XML (DB2)
* CLOB
* BLOB
* (DB2) Use INLINE option
* VARCHAR(32000)


