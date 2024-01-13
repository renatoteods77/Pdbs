

-- Verificar modo de undo e archive

SELECT LOG_MODE FROM V$DATABASE;

SELECT * FROM DATABASE_PROPERTIES WHERE PROPERTY_NAME='LOCAL_UNDO_ENABLED';

-- CLONANDO LOCAL PDB

CREATE PLUGGABLE DATABASE ORCLPDB FROM ORCLPDB2;

ALTER PLUGGABLE DATABASE ORCLPDB OPEN;

-- CLONANDO LOCAL PDB VIA DBCA

dbca -silent \
    -createpluggabledatabase \
    -sourcedb orcl \
    -createpdbfrom PDB \
    -pdbName ORCLPDBCLONE \
    -sourcepdb ORCLPDB

-- sourcedb onde ficará o pdb

-- CLONANDO PDB REMOTO (ORIGEM: ORCL DESTINO: ORCL2)

-- NA ORIGEM

CREATE USER c##conector IDENTIFIED BY senha CONTAINER=ALL;

GRANT CREATE SESSION, CREATE PLUGGABLE DATABASE TO c##conector CONTAINER=ALL;

-- NO DESTINO

CREATE DATABASE LINK orcl_link CONNECT TO c##conector IDENTIFIED BY senha USING 'ORCL';

CREATE PLUGGABLE DATABASE ORCLPDBCOPY FROM ORCLPDB@orcl_link;

ALTER PLUGGABLE DATABASE ORCLPDBCOPY OPEN;

-- CLONANDO PDB REMOTO VIA DBCA

dbca -silent \
  -createPluggableDatabase \
  -createFromRemotePDB \
    -pdbName ORCLPDBCLONE2 \
    -sourceDB orcl2 \
    -createAsClone true \
    -remotePDBName ORCLPDB \
    -remoteDBConnString ol7-dba:1521/orcl.localdomain \
    -sysDBAUserName sys \
    -sysDBAPassword senha \
    -remoteDBSYSDBAUserName sys \
    -remoteDBSYSDBAUserPassword senha \
    -dbLinkUsername c##conector \
    -dbLinkUserPassword senha 

-- verificar db link na origem enquanto clona:
SET LINES 400
COL DB_LINK FOR a40
COL USERNAME FOR A30
COL HOST FOR A50
SELECT DB_LINK, HOST, USERNAME, CREATED FROM DBA_DB_LINKS;

-- verificar historico de conexoes no destino:

set lines 400
col db_name for a20
col USERNAME for a20
col LAST_LOGON_TIME for a40
SELECT DB_NAME, USERNAME, LAST_LOGON_TIME, LOGON_COUNT FROM DBA_DB_LINK_SOURCES;


-- REFRESHABLE PDB

-- origem (orcl)

CREATE PLUGGABLE DATABASE src_pdb ADMIN USER dbaocm IDENTIFIED BY senha;

ALTER PLUGGABLE DATABASE src_pdb OPEN;

CREATE USER c##ref_admin IDENTIFIED BY senha;

GRANT CREATE SESSION, RESOURCE, CREATE ANY TABLE, UNLIMITED TABLESPACE TO c##ref_admin CONTAINER=ALL;

GRANT CREATE PLUGGABLE DATABASE TO c##ref_admin CONTAINER=ALL;

GRANT SYSOPER TO c##ref_admin CONTAINER=ALL;


-- destino (orcl2)

CREATE USER c##ref_admin IDENTIFIED BY senha;

GRANT CREATE SESSION, RESOURCE, CREATE ANY TABLE, UNLIMITED TABLESPACE TO c##ref_admin CONTAINER=ALL;

GRANT CREATE PLUGGABLE DATABASE TO c##ref_admin CONTAINER=ALL;

GRANT SYSOPER TO c##ref_admin CONTAINER=ALL;

CREATE DATABASE LINK ref_dblink CONNECT TO c##ref_admin IDENTIFIED BY senha USING 'ORCL';

CREATE PLUGGABLE DATABASE ref_pdb FROM src_pdb@ref_dblink REFRESH MODE MANUAL;

ALTER PLUGGABLE DATABASE ref_pdb OPEN READ ONLY;

SELECT last_refresh_scn FROM dba_pdbs WHERE pdb_name = 'REF_PDB';

COL PDB_NAME FOR A25
SELECT PDB_NAME, REFRESH_MODE, REFRESH_INTERVAL FROM DBA_PDBS;

-- origem


ALTER SESSION SET CONTAINER=src_pdb;

CREATE TABLE t1(n1 NUMBER);

INSERT INTO t1 VALUES(1);

COMMIT;

-- destino

ALTER SESSION SET CONTAINER = ref_pdb;

SELECT * FROM T1;

ALTER PLUGGABLE DATABASE ref_pdb CLOSE IMMEDIATE;

ALTER PLUGGABLE DATABASE REFRESH;

ALTER PLUGGABLE DATABASE ref_pdb OPEN READ ONLY;

SELECT * FROM T1;

SELECT last_refresh_scn FROM dba_pdbs WHERE pdb_name = 'REF_PDB';

-- origem

ALTER SESSION SET CONTAINER=cdb$root;

CREATE DATABASE LINK ref_dblink CONNECT TO c##ref_admin IDENTIFIED BY senha USING 'ORCL2';

ALTER SESSION SET CONTAINER = src_pdb;

ALTER PLUGGABLE DATABASE REFRESH MODE EVERY 60 MINUTES FROM ref_pdb@ref_dblink SWITCHOVER;

ALTER SESSION SET CONTAINER=cdb$root;

alter system set "_exadata_feature_on"=true scope=spfile;

shutdown immediate

startup

ALTER PLUGGABLE DATABASE src_pdb OPEN;

ALTER SESSION SET CONTAINER = src_pdb;

ALTER PLUGGABLE DATABASE REFRESH MODE EVERY 60 MINUTES FROM ref_pdb@ref_dblink SWITCHOVER;

show pdbs

ALTER PLUGGABLE DATABASE OPEN READ ONLY;

-- destino

ALTER SESSION SET CONTAINER=ref_pdb;

CREATE TABLE t2(n1 NUMBER);

INSERT INTO t2 VALUES(1);

COMMIT;

-- origem

ALTER SESSION SET CONTAINER = src_pdb;

SELECT * FROM T2;

SELECT last_refresh_scn FROM dba_pdbs WHERE pdb_name = 'SRC_PDB';

ALTER PLUGGABLE DATABASE src_pdb CLOSE IMMEDIATE;

ALTER PLUGGABLE DATABASE REFRESH;

ALTER PLUGGABLE DATABASE src_pdb OPEN READ ONLY;

SELECT last_refresh_scn FROM dba_pdbs WHERE pdb_name = 'SRC_PDB';

SELECT * FROM T2;



-- CLONE NON-CDB

-- no non-cdb

CREATE USER conector IDENTIFIED BY senha;

GRANT CREATE SESSION, CREATE PLUGGABLE DATABASE TO conector;

-- no cdb

CREATE TABLE Livros (
    LivroID NUMBER,
    Titulo VARCHAR2(50),
    Autor VARCHAR2(50),
    Genero VARCHAR2(50),
    DataPublicacao DATE
);

INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (1, 'Harry Potter e a Pedra Filosofal', 'J.K. Rowling', 'Fantasia', TO_DATE('1997-06-26', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (2, '1984', 'George Orwell', 'Distopia', TO_DATE('1949-06-08', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (3, 'O Hobbit', 'J.R.R. Tolkien', 'Fantasia', TO_DATE('1937-09-21', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (4, 'Assassinato no Expresso do Oriente', 'Agatha Christie', 'Misterio', TO_DATE('1934-01-01', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (5, 'As Aventuras de Tom Sawyer', 'Mark Twain', 'Aventura', TO_DATE('1876-06-16', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (6, 'Orgulho e Preconceito', 'Jane Austen', 'Romance', TO_DATE('1813-01-28', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (7, 'O Grande Gatsby', 'F. Scott Fitzgerald', 'Romance', TO_DATE('1925-04-10', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (8, 'O Velho e o Mar', 'Ernest Hemingway', 'Ficcao', TO_DATE('1952-09-01', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (9, 'O Iluminado', 'Stephen King', 'Terror', TO_DATE('1977-01-28', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (10, 'Frankenstein', 'Mary Shelley', 'Gotico', TO_DATE('1818-01-01', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (11, 'A Dança da Morte', 'Stephen King', 'Pos-Apocaliptico', TO_DATE('1978-10-03', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (12, 'Um Conto de Duas Cidades', 'Mark Twain', 'Historico', TO_DATE('1859-04-30', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (13, 'Emma', 'Jane Austen', 'Romance', TO_DATE('1815-12-23', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (14, 'O Sol Tambem Se Levanta', 'Ernest Hemingway', 'Romance', TO_DATE('1926-10-22', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (15, 'Harry Potter e a Câmara Secreta', 'J.K. Rowling', 'Fantasia', TO_DATE('1998-07-02', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (16, 'A Coisa', 'Stephen King', 'Terror', TO_DATE('1986-09-15', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (17, 'A Revolução dos Bichos', 'George Orwell', 'Politico', TO_DATE('1945-08-17', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (18, 'O Apanhador no Campo de Centeio', 'F. Scott Fitzgerald', 'Romance', TO_DATE('1951-07-16', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (19, 'Moby Dick', 'Mark Twain', 'Aventura', TO_DATE('1851-10-18', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (20, 'O Silmarillion', 'J.R.R. Tolkien', 'Fantasia', TO_DATE('1977-09-15', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (21, 'Harry Potter e o Prisioneiro de Azkaban', NULL, 'Fantasia', TO_DATE('1999-07-08', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (22, 'O Senhor dos Aneis: A Sociedade do Anel', NULL, 'Fantasia', TO_DATE('1954-07-29', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (23, 'Desespero', NULL, 'Terror', TO_DATE('1996-09-01', 'YYYY-MM-DD'));
COMMIT;

SELECT COUNT(*) FROM LIVROS;

SELECT LOG_MODE FROM V$DATABASE;

-- destino

CREATE DATABASE LINK non_cdb_dblink CONNECT TO conector IDENTIFIED BY senha USING 'NONCDB';

CREATE PLUGGABLE DATABASE pdb_from_noncdb FROM noncdb@non_cdb_dblink;

show pdbs

ALTER SESSION SET CONTAINER=pdb_from_noncdb;

@?/rdbms/admin/noncdb_to_pdb.sql

ALTER PLUGGABLE DATABASE pdb_from_noncdb OPEN;

SELECT COUNT(*) FROM LIVROS;


-- UNPLUG PDB XML

CREATE PLUGGABLE DATABASE ORCLPDB2 ADMIN USER PDBADMIN IDENTIFIED BY senha;

CREATE TABLE Livros (
    LivroID NUMBER,
    Titulo VARCHAR2(50),
    Autor VARCHAR2(50),
    Genero VARCHAR2(50),
    DataPublicacao DATE
);

INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (1, 'Harry Potter e a Pedra Filosofal', 'J.K. Rowling', 'Fantasia', TO_DATE('1997-06-26', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (2, '1984', 'George Orwell', 'Distopia', TO_DATE('1949-06-08', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (3, 'O Hobbit', 'J.R.R. Tolkien', 'Fantasia', TO_DATE('1937-09-21', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (4, 'Assassinato no Expresso do Oriente', 'Agatha Christie', 'Misterio', TO_DATE('1934-01-01', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (5, 'As Aventuras de Tom Sawyer', 'Mark Twain', 'Aventura', TO_DATE('1876-06-16', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (6, 'Orgulho e Preconceito', 'Jane Austen', 'Romance', TO_DATE('1813-01-28', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (7, 'O Grande Gatsby', 'F. Scott Fitzgerald', 'Romance', TO_DATE('1925-04-10', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (8, 'O Velho e o Mar', 'Ernest Hemingway', 'Ficcao', TO_DATE('1952-09-01', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (9, 'O Iluminado', 'Stephen King', 'Terror', TO_DATE('1977-01-28', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (10, 'Frankenstein', 'Mary Shelley', 'Gotico', TO_DATE('1818-01-01', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (11, 'A Dança da Morte', 'Stephen King', 'Pos-Apocaliptico', TO_DATE('1978-10-03', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (12, 'Um Conto de Duas Cidades', 'Mark Twain', 'Historico', TO_DATE('1859-04-30', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (13, 'Emma', 'Jane Austen', 'Romance', TO_DATE('1815-12-23', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (14, 'O Sol Tambem Se Levanta', 'Ernest Hemingway', 'Romance', TO_DATE('1926-10-22', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (15, 'Harry Potter e a Câmara Secreta', 'J.K. Rowling', 'Fantasia', TO_DATE('1998-07-02', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (16, 'A Coisa', 'Stephen King', 'Terror', TO_DATE('1986-09-15', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (17, 'A Revolução dos Bichos', 'George Orwell', 'Politico', TO_DATE('1945-08-17', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (18, 'O Apanhador no Campo de Centeio', 'F. Scott Fitzgerald', 'Romance', TO_DATE('1951-07-16', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (19, 'Moby Dick', 'Mark Twain', 'Aventura', TO_DATE('1851-10-18', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (20, 'O Silmarillion', 'J.R.R. Tolkien', 'Fantasia', TO_DATE('1977-09-15', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (21, 'Harry Potter e o Prisioneiro de Azkaban', NULL, 'Fantasia', TO_DATE('1999-07-08', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (22, 'O Senhor dos Aneis: A Sociedade do Anel', NULL, 'Fantasia', TO_DATE('1954-07-29', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (23, 'Desespero', NULL, 'Terror', TO_DATE('1996-09-01', 'YYYY-MM-DD'));
COMMIT;

ALTER PLUGGABLE DATABASE orclpdb2 CLOSE IMMEDIATE;

ALTER PLUGGABLE DATABASE orclpdb2 UNPLUG INTO '/home/oracle/orclpdb2.xml';

vi /home/oracle/orclpdb2.xml

SHOW PDBS

ALTER PLUGGABLE DATABASE orclpdb2 OPEN;

DROP PLUGGABLE DATABASE orclpdb2 KEEP DATAFILES;

-- PLUGANDO PDB XML NO MESMO CDB

CREATE PLUGGABLE DATABASE orclpdb2 USING '/home/oracle/orclpdb2.xml';

ALTER PLUGGABLE DATABASE orclpdb2 OPEN;


-- SOURCE_FILE_NAME_CONVERT

ALTER PLUGGABLE DATABASE orclpdb2 CLOSE IMMEDIATE;

!mkdir /home/oracle/orclpdb2

ALTER PLUGGABLE DATABASE orclpdb2 UNPLUG INTO '/home/oracle/orclpdb2/orclpdb2.xml';

DROP PLUGGABLE DATABASE orclpdb2 KEEP DATAFILES;

cat /home/oracle/orclpdb2/orclpdb2.xml | grep /u02

mv /u02/oradata/ORCL2/FDA0011D3DDD6158E0532D64A8C03C65/datafile/o1_mf_system_lmogtqjn_.dbf /home/oracle/orclpdb2
mv /u02/oradata/ORCL2/FDA0011D3DDD6158E0532D64A8C03C65/datafile/o1_mf_sysaux_lmogtqjv_.dbf /home/oracle/orclpdb2
mv /u02/oradata/ORCL2/FDA0011D3DDD6158E0532D64A8C03C65/datafile/o1_mf_undotbs1_lmogtqjx_.dbf /home/oracle/orclpdb2
mv /u02/oradata/ORCL2/FDA0011D3DDD6158E0532D64A8C03C65/datafile/o1_mf_temp_lmogtqjx_.dbf /home/oracle/orclpdb2
mv /u02/oradata/ORCL2/FDA0011D3DDD6158E0532D64A8C03C65/datafile/o1_mf_users_lmogtqjx_.dbf /home/oracle/orclpdb2
mv /u02/oradata/ORCL2/FDA0011D3DDD6158E0532D64A8C03C65/datafile/o1_mf_sales_q1_lmogtqjy_.dbf /home/oracle/orclpdb2
mv /u02/oradata/ORCL2/FDA0011D3DDD6158E0532D64A8C03C65/datafile/o1_mf_big_tbs_lmogtqjy_.dbf /home/oracle/orclpdb2
mv /u02/oradata/ORCL2/FDA0011D3DDD6158E0532D64A8C03C65/datafile/o1_mf_sales_lmogtqjy_.dbf /home/oracle/orclpdb2
mv /u02/oradata/ORCL2/FDA0011D3DDD6158E0532D64A8C03C65/datafile/o1_mf_sales_lmogtqjz_.dbf /home/oracle/orclpdb2
mv /u02/oradata/ORCL2/FDA0011D3DDD6158E0532D64A8C03C65/datafile/o1_mf_carros_t_lmogtqjz_.dbf /home/oracle/orclpdb2
mv /u02/oradata/ORCL2/FDA0011D3DDD6158E0532D64A8C03C65/datafile/o1_mf_undotbs2_lmogtqk0_.dbf /home/oracle/orclpdb2
mv /u02/oradata/ORCL2/FDA0011D3DDD6158E0532D64A8C03C65/datafile/o1_mf_tbs_resu_lmogtqk0_.dbf /home/oracle/orclpdb2


-- no destino

SET SERVEROUTPUT ON
DECLARE
  compatible CONSTANT VARCHAR2(3) := 
    CASE DBMS_PDB.CHECK_PLUG_COMPATIBILITY(
           pdb_descr_file => '/home/oracle/orclpdb2/orclpdb2.xml',
           pdb_name       => 'ORCLPDB2')
    WHEN TRUE THEN 'YES'
    ELSE 'NO'
END;
BEGIN
  DBMS_OUTPUT.PUT_LINE(compatible);
END;
/


CREATE PLUGGABLE DATABASE orclpdb2 USING '/home/oracle/orclpdb2/orclpdb2.xml';

CREATE PLUGGABLE DATABASE orclpdb2 USING '/home/oracle/orclpdb2/orclpdb2.xml' 
SOURCE_FILE_NAME_CONVERT=('/u02/oradata/ORCL2/FDA0011D3DDD6158E0532D64A8C03C65/datafile/', '/home/oracle/orclpdb2/');

ALTER PLUGGABLE DATABASE orclpdb2 OPEN;


-- SOURCE_FILE_DIRECTORY

CREATE PLUGGABLE DATABASE orclpdb2 USING '/home/oracle/orclpdb2/orclpdb2.xml' 
SOURCE_FILE_DIRECTORY='/home/oracle/orclpdb2/';

ALTER PLUGGABLE DATABASE orclpdb2 OPEN;

-- UNPLUG PARA PDB ARCHIVE FILE

ALTER PLUGGABLE DATABASE orclpdb2 CLOSE IMMEDIATE;

ALTER PLUGGABLE DATABASE orclpdb2 UNPLUG INTO '/home/oracle/orclpdb2.pdb';

DROP PLUGGABLE DATABASE orclpdb2 INCLUDING DATAFILES;

-- no destino

ls -lh /home/oracle/orclpdb2/

SET SERVEROUTPUT ON
DECLARE
  compatible CONSTANT VARCHAR2(3) := 
    CASE DBMS_PDB.CHECK_PLUG_COMPATIBILITY(
           pdb_descr_file => '/home/oracle/orclpdb2/orclpdb2.pdb',
           pdb_name       => 'PDB2')
    WHEN TRUE THEN 'YES'
    ELSE 'NO'
END;
BEGIN
  DBMS_OUTPUT.PUT_LINE(compatible);
END;
/


CREATE PLUGGABLE DATABASE pdb2 USING '/home/oracle/orclpdb2/orclpdb2.pdb';

-- GERAR XML COM DBMS_PDB.DESCRIBE

BEGIN
  DBMS_PDB.DESCRIBE(
    pdb_descr_file => '/home/oracle/orclpdb.xml',
    pdb_name       => 'ORCLPDB');
END;
/



-- GERAR XML DE NON-CDB PARA MIGRAÇÃO PARA PDB


-- NO NONCDB

CREATE TABLE Livros (
    LivroID NUMBER,
    Titulo VARCHAR2(50),
    Autor VARCHAR2(50),
    Genero VARCHAR2(50),
    DataPublicacao DATE
);

INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (1, 'Harry Potter e a Pedra Filosofal', 'J.K. Rowling', 'Fantasia', TO_DATE('1997-06-26', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (2, '1984', 'George Orwell', 'Distopia', TO_DATE('1949-06-08', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (3, 'O Hobbit', 'J.R.R. Tolkien', 'Fantasia', TO_DATE('1937-09-21', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (4, 'Assassinato no Expresso do Oriente', 'Agatha Christie', 'Misterio', TO_DATE('1934-01-01', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (5, 'As Aventuras de Tom Sawyer', 'Mark Twain', 'Aventura', TO_DATE('1876-06-16', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (6, 'Orgulho e Preconceito', 'Jane Austen', 'Romance', TO_DATE('1813-01-28', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (7, 'O Grande Gatsby', 'F. Scott Fitzgerald', 'Romance', TO_DATE('1925-04-10', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (8, 'O Velho e o Mar', 'Ernest Hemingway', 'Ficcao', TO_DATE('1952-09-01', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (9, 'O Iluminado', 'Stephen King', 'Terror', TO_DATE('1977-01-28', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (10, 'Frankenstein', 'Mary Shelley', 'Gotico', TO_DATE('1818-01-01', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (11, 'A Dança da Morte', 'Stephen King', 'Pos-Apocaliptico', TO_DATE('1978-10-03', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (12, 'Um Conto de Duas Cidades', 'Mark Twain', 'Historico', TO_DATE('1859-04-30', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (13, 'Emma', 'Jane Austen', 'Romance', TO_DATE('1815-12-23', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (14, 'O Sol Tambem Se Levanta', 'Ernest Hemingway', 'Romance', TO_DATE('1926-10-22', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (15, 'Harry Potter e a Câmara Secreta', 'J.K. Rowling', 'Fantasia', TO_DATE('1998-07-02', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (16, 'A Coisa', 'Stephen King', 'Terror', TO_DATE('1986-09-15', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (17, 'A Revolução dos Bichos', 'George Orwell', 'Politico', TO_DATE('1945-08-17', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (18, 'O Apanhador no Campo de Centeio', 'F. Scott Fitzgerald', 'Romance', TO_DATE('1951-07-16', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (19, 'Moby Dick', 'Mark Twain', 'Aventura', TO_DATE('1851-10-18', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (20, 'O Silmarillion', 'J.R.R. Tolkien', 'Fantasia', TO_DATE('1977-09-15', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (21, 'Harry Potter e o Prisioneiro de Azkaban', NULL, 'Fantasia', TO_DATE('1999-07-08', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (22, 'O Senhor dos Aneis: A Sociedade do Anel', NULL, 'Fantasia', TO_DATE('1954-07-29', 'YYYY-MM-DD'));
INSERT INTO Livros (LivroID, Titulo, Autor, Genero, DataPublicacao) VALUES (23, 'Desespero', NULL, 'Terror', TO_DATE('1996-09-01', 'YYYY-MM-DD'));
COMMIT;

SHUTDOWN IMMEDIATE;
STARTUP MOUNT

ALTER DATABASE OPEN READ ONLY;

BEGIN
  DBMS_PDB.DESCRIBE(
    pdb_descr_file => '/home/oracle/noncdb.xml');
END;
/

-- no CDB destino

SET SERVEROUTPUT ON
DECLARE
  compatible CONSTANT VARCHAR2(3) := 
    CASE DBMS_PDB.CHECK_PLUG_COMPATIBILITY(
           pdb_descr_file => '/home/oracle/noncdb.xml',
           pdb_name       => 'NONCDB_PDB')
    WHEN TRUE THEN 'YES'
    ELSE 'NO'
END;
BEGIN
  DBMS_OUTPUT.PUT_LINE(compatible);
END;
/

CREATE PLUGGABLE DATABASE NONCDB_PDB USING '/home/oracle/noncdb.xml';

ALTER SESSION SET CONTAINER=NONCDB_PDB;

@?/rdbms/admin/noncdb_to_pdb.sql

ALTER PLUGGABLE DATABASE NONCDB_PDB OPEN;

SELECT COUNT(*) FROM LIVROS;



-- Realocação de PDBs


-- source orcl
-- dest orcl2 


-- relocate cdb mesmo host

-- criacao de usuario

-- source

SELECT PROPERTY_NAME, PROPERTY_VALUE 
FROM   DATABASE_PROPERTIES 
WHERE  PROPERTY_NAME = 'LOCAL_UNDO_ENABLED';

SELECT LOG_MODE FROM V$DATABASE;

CREATE USER c##conector IDENTIFIED BY senha;

GRANT CREATE SESSION, CREATE PLUGGABLE DATABASE, SYSOPER TO c##conector CONTAINER=ALL;

ALTER SESSION SET CONTAINER=pdb;

create user teste identified by senha;

grant dba, resource, connect to teste;

sqlplus teste/senha@ol7-dba:1521/orclpdb2.localdomain
-- ou
sqlplus teste/senha@orclpdb2

SELECT DBID, NAME, CREATED FROM V$DATABASE;

-- dest

CREATE PUBLIC DATABASE LINK orcl2link CONNECT TO c##conector IDENTIFIED BY senha USING 'ORCL2';

-- omf habilitado
show parameter db_create

-- acompanhar alerts

tail -f $ORACLE_BASE/diag/rdbms/orcl2/orcl2/trace/alert

tail -f $ORACLE_BASE/diag/rdbms/orcl/orcl/trace/alert

CREATE PLUGGABLE DATABASE pdb FROM pdb5@orcl2link RELOCATE AVAILABILITY NORMAL;

ALTER PLUGGABLE DATABASE pdb OPEN;

-- source

DROP PLUGGABLE DATABASE pdb INCLUDING DATAFILES;



-- realocação via dbca silent mode

-- source

SELECT PROPERTY_NAME, PROPERTY_VALUE 
FROM   DATABASE_PROPERTIES 
WHERE  PROPERTY_NAME = 'LOCAL_UNDO_ENABLED';

SELECT LOG_MODE FROM V$DATABASE;

CREATE USER c##conector IDENTIFIED BY senha;

GRANT CREATE SESSION, CREATE PLUGGABLE DATABASE, SYSOPER TO c##conector CONTAINER=ALL;

ALTER SESSION SET CONTAINER=orclpdb2;

create user teste identified by senha;

grant dba, resource, connect to teste;

sqlplus teste/senha@ol7-dba:1521/orclpdb2.localdomain
-- ou
sqlplus teste/senha@orclpdb2

SELECT DBID, NAME, CREATED FROM V$DATABASE;

-- dest

dbca -silent  \
-relocatePDB \
-sourceDB orcl2   \
-remotePDBName orclpdb2  \
-remoteDBConnString ol7-dba:1521/orcl.localdomain  \
-remoteDBSYSDBAUserName sys  \
-remoteDBSYSDBAUserPassword senha  \
-dbLinkUsername c##conector  \
-dbLinkUserPassword senha  \
-sysDBAUserName sys  \
-sysDBAPassword senha \
-pdbName orclpdb2

sqlplus teste/senha@orclpdb2

SELECT DBID, NAME, CREATED FROM V$DATABASE;

dbca -silent  \
-relocatePDB \
-sourceDB cdb3   \
-remotePDBName pdb5  \
-remoteDBConnString ol7-dba2:1521/orcl2.localdomain  \
-remoteDBSYSDBAUserName sys  \
-remoteDBSYSDBAUserPassword senha  \
-dbLinkUsername c##conector  \
-dbLinkUserPassword senha  \
-sysDBAUserName sys  \
-sysDBAPassword senha \
-pdbName pdb5



-- PDB Snapshot Carousel



-- criando pdb como modo de snapshot manual

SELECT * FROM DATABASE_PROPERTIES WHERE PROPERTY_NAME='LOCAL_UNDO_ENABLED';

CREATE PLUGGABLE DATABASE pdb_snap_manual SNAPSHOT MODE MANUAL 
ADMIN USER PDBADMIN IDENTIFIED BY senha;


-- workaround

alter system set "_exadata_feature_on"=true scope=spfile;
shutdown immediate;
startup;


-- VERIFICANDO MODO DE SNAPSHOT

COL PDB_NAME FOR A20
SELECT PDB_NAME, SNAPSHOT_MODE, SNAPSHOT_INTERVAL FROM DBA_PDBS;

-- criando pdb como modo de snapshot manual

CREATE PLUGGABLE DATABASE pdb_snap_manual SNAPSHOT MODE MANUAL 
ADMIN USER PDBADMIN IDENTIFIED BY senha;


COL PDB_NAME FOR A20
SELECT PDB_NAME, SNAPSHOT_MODE, SNAPSHOT_INTERVAL FROM DBA_PDBS;

-- criando pdb como modo de snapshot automatico

CREATE PLUGGABLE DATABASE pdb_snap_hour SNAPSHOT MODE EVERY 24 HOURS 
ADMIN USER PDBADMIN IDENTIFIED BY senha;


CREATE PLUGGABLE DATABASE pdb_snap_minutes SNAPSHOT MODE EVERY 120 MINUTES 
ADMIN USER PDBADMIN IDENTIFIED BY senha;

COL PDB_NAME FOR A20
SELECT PDB_NAME, SNAPSHOT_MODE, SNAPSHOT_INTERVAL FROM DBA_PDBS;

-- criando pdb como modo de snapshot desabilitado

CREATE PLUGGABLE DATABASE pdb_snap_none SNAPSHOT MODE NONE 
ADMIN USER PDBADMIN IDENTIFIED BY senha;

COL PDB_NAME FOR A20
SELECT PDB_NAME, SNAPSHOT_MODE, SNAPSHOT_INTERVAL FROM DBA_PDBS;

-- alterando modo de snapshot

ALTER PLUGGABLE DATABASE pdb_snap_hour SNAPSHOT MODE MANUAL;

ALTER SESSION SET CONTAINER=pdb_snap_hour;

ALTER PLUGGABLE DATABASE SNAPSHOT MODE MANUAL;

ALTER SESSION SET CONTAINER=pdb_snap_none;

ALTER PLUGGABLE DATABASE SNAPSHOT MODE MANUAL;

ALTER SESSION SET CONTAINER=cdb$root;

COL PDB_NAME FOR A20
SELECT PDB_NAME, SNAPSHOT_MODE, SNAPSHOT_INTERVAL FROM DBA_PDBS;


-- numero maximo de snapshots

alter pluggable database all open;

SET LINESIZE 150
set pages 999
COL ID FORMAT 99
COL PROPERTY_NAME FORMAT a17
COL PDB_NAME FORMAT a20
COL VALUE FORMAT a3
COL DESCRIPTION FORMAT a43

SELECT r.CON_ID AS id, p.PDB_NAME, PROPERTY_NAME, 
       PROPERTY_VALUE AS value, DESCRIPTION 
FROM   CDB_PROPERTIES r, CDB_PDBS p 
WHERE  r.CON_ID = p.CON_ID 
AND    PROPERTY_NAME LIKE 'MAX_PDB%' 
ORDER BY PROPERTY_NAME;

ALTER SESSION SET CONTAINER=orclpdb;

ALTER PLUGGABLE DATABASE SET MAX_PDB_SNAPSHOTS=7;

ALTER SESSION SET CONTAINER=cdb$root;

SELECT r.CON_ID AS id, p.PDB_NAME, PROPERTY_NAME, 
       PROPERTY_VALUE AS value, DESCRIPTION 
FROM   CDB_PROPERTIES r, CDB_PDBS p 
WHERE  r.CON_ID = p.CON_ID 
AND    PROPERTY_NAME LIKE 'MAX_PDB%' 
ORDER BY PROPERTY_NAME;


-- snapshot manual

ALTER SESSION SET CONTAINER=orclpdb;

ALTER PLUGGABLE DATABASE SNAPSHOT;

SET LINESIZE 150
COL CON_NAME FORMAT a9
COL ID FORMAT 99
COL SNAPSHOT_NAME FORMAT a30
COL SNAP_SCN FORMAT 9999999
COL FULL_SNAPSHOT_PATH FORMAT a61

SELECT CON_ID AS ID, CON_NAME, SNAPSHOT_NAME, 
       SNAPSHOT_SCN AS snap_scn, FULL_SNAPSHOT_PATH 
FROM   DBA_PDB_SNAPSHOTS
ORDER BY SNAP_SCN;


ALTER PLUGGABLE DATABASE SNAPSHOT my_snapshot;

COL CON_ID FORMAT 999999
COL CON_NAME FORMAT a15
COL SNAPSHOT_NAME FORMAT a27

SELECT CON_ID, CON_NAME, SNAPSHOT_NAME, SNAPSHOT_SCN FROM DBA_PDB_SNAPSHOTS;

-- clonando pdb a partir de um snapshot

CREATE TABLE T1 (C1 NUMBER);

INSERT INTO T1 VALUES(1);
INSERT INTO T1 VALUES(2);
INSERT INTO T1 VALUES(3);
INSERT INTO T1 VALUES(4);
INSERT INTO T1 VALUES(5);
COMMIT;

SELECT * FROM T1;

ALTER PLUGGABLE DATABASE SNAPSHOT snapshot_for_clone;

ALTER SESSION SET CONTAINER=cdb$root;

COL CON_ID FORMAT 999999
COL CON_NAME FORMAT a15
COL SNAPSHOT_NAME FORMAT a27

SELECT CON_ID, CON_NAME, SNAPSHOT_NAME, SNAPSHOT_SCN FROM DBA_PDB_SNAPSHOTS;

CREATE PLUGGABLE DATABASE orclpdb_copy FROM orclpdb USING SNAPSHOT snapshot_for_clone;

ALTER PLUGGABLE DATABASE orclpdb_copy OPEN;

ALTER SESSION SET CONTAINER=orclpdb_copy;

SELECT * FROM T1;

-- drop de snapshot

ALTER PLUGGABLE DATABASE DROP SNAPSHOT my_snapshot;

COL CON_ID FORMAT 999999
COL CON_NAME FORMAT a15
COL SNAPSHOT_NAME FORMAT a27

SELECT CON_ID, CON_NAME, SNAPSHOT_NAME, SNAPSHOT_SCN FROM DBA_PDB_SNAPSHOTS;

ALTER PLUGGABLE DATABASE SET MAX_PDB_SNAPSHOTS=0;

-- SNAPSHOT COPY PDB

ALTER SYSTEM SET CLONEDB=TRUE SCOPE=SPFILE;

SHUTDOWN IMMEDIATE;

STARTUP

ALTER PLUGGABLE DATABASE orclpdb OPEN READ ONLY FORCE;

CREATE PLUGGABLE DATABASE snap_copy FROM orclpdb SNAPSHOT COPY;

ALTER PLUGGABLE DATABASE snap_copy OPEN;

SHOW PDBS

SELECT CON_ID, FILE_NAME FROM CDB_DATA_FILES WHERE CON_ID IN (4,10);

!ls -lhs caminho

!ls -lhs caminho

ALTER SESSION SET CONTAINER=snap_copy;

CREATE TABLE OBJECTS AS SELECT * FROM DBA_OBJECTS;

SELECT TABLESPACE_NAME FROM DBA_TABLES WHERE TABLE_NAME='OBJECTS';

!ls -lhs caminho

!ls -lhs caminho

-- materializando

ALTER SESSION SET CONTAINER=snap_copy;

ALTER PLUGGABLE DATABASE MATERIALIZE;

!ls -lhs caminho
