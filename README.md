


-- criando PDBs

-- com OMF:

SHOW PARAMETER DB_CREATE

ALTER SYSTEM SET DB_CREATE_FILE_DEST='/u02/oradata';

CREATE PLUGGABLE DATABASE orclpdb2 ADMIN USER pdb_admin IDENTIFIED BY senha;

ALTER PLUGGABLE DATABASE orclpdb2 OPEN;

ALTER SESSION SET CONTAINER=orclpdb2;

SHOW PARAMETER DB_CREATE

SELECT FILE_NAME FROM DBA_DATA_FILES;

SET LINES WINDOW
SET PAGES 999
SELECT USERNAME, COMMON FROM DBA_USERS WHERE COMMON='NO';

SELECT GRANTEE, GRANTED_ROLE, ADMIN_OPTION FROM DBA_ROLE_PRIVS WHERE GRANTEE = 'PDB_ADMIN';

SELECT PRIVILEGE, ADMIN_OPTION FROM ROLE_SYS_PRIVS WHERE ROLE = 'PDB_DBA';

COL TABLE_NAME FOR A50
SELECT TABLE_NAME, PRIVILEGE FROM ROLE_TAB_PRIVS WHERE ROLE = 'PDB_DBA';

ALTER SESSION SET CONTAINER=cdb$root;

CREATE PLUGGABLE DATABASE pdb_roles 
ADMIN USER pdb_admin IDENTIFIED BY senha
ROLES=(DBA, CONNECT, RESOURCE);

ALTER PLUGGABLE DATABASE pdb_roles OPEN;

ALTER SESSION SET CONTAINER=pdb_roles;

SELECT GRANTEE, GRANTED_ROLE, ADMIN_OPTION FROM DBA_ROLE_PRIVS WHERE GRANTEE = 'PDB_ADMIN';

COL ROLE FOR A50
COL GRANTED_ROLE FOR A50
SELECT ROLE, GRANTED_ROLE, ADMIN_OPTION FROM ROLE_ROLE_PRIVS WHERE ROLE = 'PDB_DBA';

-- FILE_NAME_CONVERT

-- SEM OMF

ALTER SESSION SET CONTAINER=cdb$root;

SHOW PDBS

ALTER SESSION SET CONTAINER=pdb$seed;

SELECT FILE_NAME FROM DBA_DATA_FILES;

ALTER SESSION SET CONTAINER=cdb$root;

CREATE PLUGGABLE DATABASE pdb_name_convert 
ADMIN USER pdb_admin IDENTIFIED BY senha
FILE_NAME_CONVERT=('/u02/oradata/ORCL2/datafile/', '/u02/oradata/ORCL2/datafile/pdb_name_convert/');

CREATE PLUGGABLE DATABASE pdb_name_convert 
ADMIN USER pdb_admin IDENTIFIED BY senha
FILE_NAME_CONVERT=('/u02/oradata/ORCL2/datafile/', '/u02/oradata/ORCL2/datafile/pdb_name_convert/pdbnc');

ALTER PLUGGABLE DATABASE pdb_name_convert OPEN;

ALTER SESSION SET CONTAINER=pdb_name_convert;

SELECT FILE_NAME FROM DBA_DATA_FILES;

-- CREATE_FILE_DEST

ALTER SESSION SET CONTAINER=cdb$root;

CREATE PLUGGABLE DATABASE pdb_omf
ADMIN USER pdb_admin IDENTIFIED BY senha
CREATE_FILE_DEST='/u02/oradata/';

ALTER PLUGGABLE DATABASE pdb_omf OPEN;

ALTER SESSION SET CONTAINER=pdb_omf;

SHOW PARAMETER DB_CREATE

SELECT FILE_NAME FROM DBA_DATA_FILES;


-- STORAGE

-- COM OMF

ALTER SESSION SET CONTAINER=cdb$root;

CREATE PLUGGABLE DATABASE pdb_storage 
ADMIN USER pdb_admin IDENTIFIED BY senha
STORAGE (MAXSIZE 5G MAX_AUDIT_SIZE 1G MAX_DIAG_SIZE UNLIMITED);

ALTER PLUGGABLE DATABASE pdb_storage OPEN;

SELECT MAX_SIZE/1024/1024 "MAX_SIZE MB", 
MAX_DIAGNOSTICS_SIZE/1024/1024 "MAX_DIAGNOSTICS_SIZE MB", 
MAX_AUDIT_SIZE/1024/1024 "MAX_AUDIT_SIZE MB" 
FROM V$PDBS 
WHERE NAME='PDB_STORAGE';

-- DEFAULT TABLESPACE

-- COM OMF

ALTER SESSION SET CONTAINER=cdb$root;

CREATE PLUGGABLE DATABASE pdb_tbs_default
ADMIN USER pdb_admin IDENTIFIED BY senha
DEFAULT TABLESPACE TBS_DEFAULT;

ALTER PLUGGABLE DATABASE pdb_tbs_default OPEN;

ALTER SESSION SET CONTAINER=pdb_tbs_default;

SELECT TABLESPACE_NAME FROM DBA_TABLESPACES;

SELECT PROPERTY_VALUE FROM DATABASE_PROPERTIES WHERE PROPERTY_NAME='DEFAULT_PERMANENT_TABLESPACE'; 

CREATE USER dbaocm IDENTIFIED BY senha;

COL USERNAME FOR A10
SELECT USERNAME, DEFAULT_TABLESPACE FROM DBA_USERS WHERE USERNAME='DBAOCM';

-- SEM OMF

-- dá erro:

CREATE PLUGGABLE DATABASE pdb_tbs_default
ADMIN USER pdb_admin IDENTIFIED BY senha
DEFAULT TABLESPACE TBS_DEFAULT;

-- correto:

CREATE PLUGGABLE DATABASE pdb_tbs_default
ADMIN USER pdb_admin IDENTIFIED BY senha
DEFAULT TABLESPACE TBS_DEFAULT
CREATE_FILE_DEST='/u02/oradata/';

ALTER PLUGGABLE DATABASE pdb_tbs_default OPEN;

ALTER SESSION SET CONTAINER=pdb_tbs_default;

SELECT FILE_NAME FROM DBA_DATA_FILES;

ALTER PLUGGABLE DATABASE pdb_tbs_default CLOSE;

ALTER SESSION SET CONTAINER=cdb$root;

DROP PLUGGABLE DATABASE pdb_tbs_default INCLUDING DATAFILES;

CREATE PLUGGABLE DATABASE pdb_tbs_default
ADMIN USER pdb_admin IDENTIFIED BY senha
FILE_NAME_CONVERT=('/u02/oradata/ORCL2/datafile/', '/u02/oradata/ORCL2/datafile/pdb_name_convert/deftbs')
DEFAULT TABLESPACE TBS_DEFAULT DATAFILE '/u02/oradata/ORCL2/my_pdb_datafile.dbf' SIZE 100M AUTOEXTEND ON NEXT 100M;

ALTER PLUGGABLE DATABASE pdb_tbs_default OPEN;

ALTER SESSION SET CONTAINER=pdb_tbs_default;

SELECT FILE_NAME FROM DBA_DATA_FILES;


-- DROP DE PDBS

ALTER SESSION SET CONTAINER=cdb$root;

ALTER PLUGGABLE DATABASE ALL CLOSE IMMEDIATE;

DROP PLUGGABLE DATABASE pdb_name_convert2 INCLUDING DATAFILES;

DROP PLUGGABLE DATABASE pdb_name_convert INCLUDING DATAFILES;

DROP PLUGGABLE DATABASE pdb_omf INCLUDING DATAFILES;

DROP PLUGGABLE DATABASE pdb_storage INCLUDING DATAFILES;

DROP PLUGGABLE DATABASE pdb_tbs_default INCLUDING DATAFILES;

DROP PLUGGABLE DATABASE PDB_ROLES INCLUDING DATAFILES;

DROP PLUGGABLE DATABASE PDB_NEW INCLUDING DATAFILES;



-- Startup e Shutdown de PDBs 




sqlplus / as sysdba

STARTUP


STARTUP PLUGGABLE DATABASE orclpdb;

ALTER PLUGGABLE DATABASE orclpdb OPEN;

ALTER SESSION SET CONTAINER=orcpdb2;

STARTUP

ALTER SESSION SET CONTAINER=CDB$ROOT;

ALTER PLUGGABLE DATABASE orclpdb SAVE STATE;

SHUTDOWN IMMEDIATE

STARTUP

SHOW PDBS

-- ABRINDO PDB SEED

ALTER PLUGGABLE DATABASE pdb$seed OPEN READ WRITE;

ALTER PLUGGABLE DATABASE pdb$seed OPEN READ WRITE FORCE;

ALTER PLUGGABLE DATABASE pdb$seed OPEN READ ONLY;

ALTER PLUGGABLE DATABASE pdb$seed OPEN READ ONLY FORCE;

-- RESTRICT

ALTER SESSION SET CONTAINER=orclpdb;

CREATE USER TESTE identified BY senha;

CREATE USER TESTE2 identified BY senha;

CREATE USER TESTE3 identified BY senha;

GRANT CREATE SESSION TO TESTE;

GRANT CREATE SESSION, RESTRICTED SESSION TO TESTE2;

GRANT CREATE SESSION, SYSDBA TO TESTE3;

ALTER SESSION SET CONTAINER=cdb$root;

COL NAME FOR A15
SELECT NAME, OPEN_MODE, RESTRICTED FROM V$PDBS;

CONN teste/senha@orclpdb

show con_name

CONN sys/SENHA@orclpdb as sysdba

ALTER PLUGGABLE DATABASE orclpdb CLOSE IMMEDIATE;

ALTER PLUGGABLE DATABASE orclpdb OPEN RESTRICTED;

COL NAME FOR A15
SELECT NAME, OPEN_MODE, RESTRICTED FROM V$PDBS;

CONN teste/senha@orclpdb

CONN teste2/senha@orclpdb

CONN teste3/senha@orclpdb AS SYSDBA

CONN sys/senha@orclpdb as sysdba

ALTER PLUGGABLE DATABASE orclpdb CLOSE IMMEDIATE;

COL NAME FOR A15
SELECT NAME, OPEN_MODE, RESTRICTED FROM V$PDBS;

CONN teste/senha@orclpdb

CONN teste2/senha@orclpdb

CONN teste3/senha@orclpdb AS SYSDBA

-- SHUTDOWN ABORT DE PDB

ALTER SESSION SET CONTAINER=orclpdb;

SHUTDOWN ABORT

tail -f $ORACLE_BASE/diag/rdbms/orcl/orcl/trace/alert_orcl.log

ALTER SESSION SET CONTAINER=cdb$root;

STARTUP PLUGGABLE DATABASE orclpdb;


-- Criando e Removendo Application Containers e Seeds

-- CRIAÇÃO DE UM APPLICATION CONTAINER


-- COM OMF:

CREATE PLUGGABLE DATABASE APP_ROOT AS APPLICATION CONTAINER ADMIN USER DBAOCM IDENTIFIED BY SENHA;

-- SEM OMF:
!mkdir /u02/oradata/APP_ROOT
CREATE PLUGGABLE DATABASE APP_ROOT AS APPLICATION CONTAINER FILE_NAME_CONVERT=('/u02/oradata/ORCL/pdbseed/','/u02/oradata/APP_ROOT') ADMIN USER DBAOCM IDENTIFIED BY SENHA;

ALTER PLUGGABLE DATABASE APP_ROOT OPEN;


-- CRIAÇÃO DE UM APPLICATION SEED:

ALTER SESSION SET CONTAINER=APP_ROOT;

CREATE PLUGGABLE DATABASE AS SEED ADMIN USER DBAOCM IDENTIFIED BY SENHA;

-- GERA ERRO:

ALTER PLUGGABLE DATABASE APP_ROOT$SEED OPEN READ ONLY;

-- MODO CORRETO:

ALTER PLUGGABLE DATABASE APP_ROOT$SEED OPEN;

ALTER SESSION SET CONTAINER=APP_ROOT$SEED;

create table t1(c1 number);

ALTER PLUGGABLE DATABASE APP_ROOT$SEED CLOSE IMMEDIATE;

ALTER PLUGGABLE DATABASE APP_ROOT$SEED OPEN READ ONLY;


-- CRIAÇÃO DE UM APPLICATION PDB

ALTER SESSION SET CONTAINER=APP_ROOT;

CREATE PLUGGABLE DATABASE APP_PDB1 ADMIN USER DBAOCM IDENTIFIED BY SENHA;

CREATE PLUGGABLE DATABASE APP_PDB2 ADMIN USER DBAOCM IDENTIFIED BY SENHA;

ALTER PLUGGABLE DATABASE ALL OPEN;

ALTER SESSION SET CONTAINER=APP_PDB2;

DESC T1

-- Consulta para verificação:

ALTER SESSION SET CONTAINER=CDB$ROOT;

COL PDB_NAME FOR A25
SELECT PDB_NAME, APPLICATION_ROOT AS ROOT, APPLICATION_PDB AS APPPDB, APPLICATION_SEED AS SEED FROM DBA_PDBS;


-- DROP APPLICATION ROOT

ALTER SESSION SET CONTAINER=CDB$ROOT;

ALTER PLUGGABLE DATABASE APP_ROOT CLOSE;

show pdbs

DROP PLUGGABLE DATABASE APP_ROOT INCLUDING DATAFILES;

DROP PLUGGABLE DATABASE APP_ROOT$SEED KEEP DATAFILES;

DROP PLUGGABLE DATABASE APP_PDB1 INCLUDING DATAFILES;

DROP PLUGGABLE DATABASE APP_PDB2 INCLUDING DATAFILES;

DROP PLUGGABLE DATABASE APP_ROOT INCLUDING DATAFILES;


-- Gerenciando Aplicações em Application Containers


-- Criação de um application container

CREATE PLUGGABLE DATABASE LIB_ROOT AS APPLICATION CONTAINER ADMIN USER DBAOCM IDENTIFIED BY SENHA;

ALTER PLUGGABLE DATABASE LIB_ROOT OPEN;

ALTER SESSION SET CONTAINER=LIB_ROOT;

CREATE PLUGGABLE DATABASE LIB_APP1 ADMIN USER DBAOCM IDENTIFIED BY SENHA;

ALTER PLUGGABLE DATABASE LIB_APP1 OPEN;

-- Instalação de uma aplicação

ALTER PLUGGABLE DATABASE APPLICATION library_app BEGIN INSTALL '1.0'; 

CREATE TABLE Livro (
    ID NUMBER PRIMARY KEY,
    Titulo VARCHAR2(20),
    Autor VARCHAR2(20),
    Ano_Publicacao NUMBER,
    ISBN VARCHAR2(13)
);

CREATE TABLE Editora SHARING=EXTENDED DATA(
    ID NUMBER PRIMARY KEY,
    Nome VARCHAR2(20),
    Endereco VARCHAR2(50)
);

CREATE TABLE Cidade SHARING=DATA(
    ID NUMBER PRIMARY KEY,
    Nome VARCHAR2(50),
    Estado VARCHAR2(30)
);


ALTER PLUGGABLE DATABASE APPLICATION library_app END INSTALL '1.0'; 

SHOW PARAMETER default_sharing

COL OBJECT_NAME FOR A10
SELECT OBJECT_NAME, OBJECT_TYPE, SHARING FROM DBA_OBJECTS WHERE OBJECT_NAME IN ('LIVRO', 'EDITORA', 'CIDADE');

-- Populando tabelas
INSERT INTO Livro (ID, Titulo, Autor, Ano_Publicacao, ISBN) VALUES (1, 'Livro 1', 'Autor 1', 2020, 'ISBN123456701');
INSERT INTO Livro (ID, Titulo, Autor, Ano_Publicacao, ISBN) VALUES (2, 'Livro 2', 'Autor 2', 2018, 'ISBN123456702');
INSERT INTO Livro (ID, Titulo, Autor, Ano_Publicacao, ISBN) VALUES (3, 'Livro 3', 'Autor 3', 2015, 'ISBN123456703');
INSERT INTO Livro (ID, Titulo, Autor, Ano_Publicacao, ISBN) VALUES (4, 'Livro 4', 'Autor 4', 2021, 'ISBN123456704');
INSERT INTO Livro (ID, Titulo, Autor, Ano_Publicacao, ISBN) VALUES (5, 'Livro 5', 'Autor 5', 2019, 'ISBN123456705');

INSERT INTO Editora (ID, Nome, Endereco) VALUES (1, 'Editora A', 'Rua da Editora A, Cidade A');
INSERT INTO Editora (ID, Nome, Endereco) VALUES (2, 'Editora B', 'Avenida da Editora B, Cidade B');
INSERT INTO Editora (ID, Nome, Endereco) VALUES (3, 'Editora C', 'PraCa da Editora C, Cidade C');

INSERT INTO Cidade (ID, Nome, Estado) VALUES (1, 'Rio de Janeiro', 'Rio de Janeiro');
INSERT INTO Cidade (ID, Nome, Estado) VALUES (2, 'Sao Paulo', 'Sao Paulo');
INSERT INTO Cidade (ID, Nome, Estado) VALUES (3, 'Belo Horizonte', 'Minas Gerais');
INSERT INTO Cidade (ID, Nome, Estado) VALUES (4, 'Porto Alegre', 'Rio Grande do Sul');
INSERT INTO Cidade (ID, Nome, Estado) VALUES (5, 'Salvador', 'Bahia');
INSERT INTO Cidade (ID, Nome, Estado) VALUES (6, 'Brasilia', 'Distrito Federal');
INSERT INTO Cidade (ID, Nome, Estado) VALUES (7, 'Recife', 'Pernambuco');
INSERT INTO Cidade (ID, Nome, Estado) VALUES (8, 'Curitiba', 'Parana');
INSERT INTO Cidade (ID, Nome, Estado) VALUES (9, 'Fortaleza', 'Ceara');
INSERT INTO Cidade (ID, Nome, Estado) VALUES (10, 'Manaus', 'Amazonas');

COMMIT;

SELECT * FROM Livro;

SELECT * FROM Editora;

SELECT * FROM Cidade;

SET LINES 400
COL APP_NAME FOR A50
SELECT APP_NAME, APP_VERSION, APP_STATUS FROM DBA_APPLICATIONS;

SET LINES 400
COL APP_NAME FOR A50
SELECT APP_NAME, APP_VERSION FROM DBA_APP_VERSIONS;

-- Criação de application PDB e sincronização

ALTER SESSION SET CONTAINER=LIB_APP1;

SET LINES 400
COL APP_NAME FOR A50
SELECT APP_NAME, APP_VERSION, APP_STATUS FROM DBA_APPLICATIONS;

SELECT * FROM Editora;

ALTER PLUGGABLE DATABASE APPLICATION library_app SYNC;

SET LINES 400
COL APP_NAME FOR A50
SELECT APP_NAME, APP_VERSION, APP_STATUS FROM DBA_APPLICATIONS;

SELECT * FROM Livro;

SELECT * FROM Editora;

SELECT * FROM Cidade;

INSERT INTO Livro (ID, Titulo, Autor, Ano_Publicacao, ISBN) VALUES (6, 'Livro 6', 'Autor 6', 2017, 'ISBN123456706');
INSERT INTO Livro (ID, Titulo, Autor, Ano_Publicacao, ISBN) VALUES (7, 'Livro 7', 'Autor 7', 2016, 'ISBN123456707');
INSERT INTO Livro (ID, Titulo, Autor, Ano_Publicacao, ISBN) VALUES (8, 'Livro 8', 'Autor 8', 2022, 'ISBN123456708');
INSERT INTO Livro (ID, Titulo, Autor, Ano_Publicacao, ISBN) VALUES (9, 'Livro 9', 'Autor 9', 2014, 'ISBN123456709');
INSERT INTO Livro (ID, Titulo, Autor, Ano_Publicacao, ISBN) VALUES (10, 'Livro 10', 'Autor 10', 2013, 'ISBN123456710');
COMMIT;

SELECT * FROM Livro;

INSERT INTO Editora (ID, Nome, Endereco) VALUES (4, 'Editora D', 'Praça da Editora D, Cidade D');
COMMIT;

SELECT * FROM Editora;

INSERT INTO Cidade (ID, Nome, Estado) VALUES (11, 'Campinas', 'Sao Paulo');

ALTER SESSION SET CONTAINER=LIB_ROOT;

INSERT INTO Cidade (ID, Nome, Estado) VALUES (11, 'Campinas', 'Sao Paulo');
COMMIT;

SELECT * FROM Cidade;

ALTER SESSION SET CONTAINER=LIB_APP1;

SELECT * FROM Cidade;

ALTER SESSION SET CONTAINER=LIB_ROOT;

COL PDB_NAME FOR A20
COL APP_NAME FOR A30
SELECT PDB_NAME, APP_NAME, APP_VERSION, APP_STATUS FROM DBA_APP_PDB_STATUS A 
JOIN DBA_PDBS P ON A.CON_UID = P.CON_UID;

SELECT * FROM CONTAINERS(LIVRO);

ALTER SESSION SET CONTAINER=LIB_APP1;

SELECT * FROM CONTAINERS(LIVRO);

-- criação do seed a partir do PDB$SEED

ALTER SESSION SET CONTAINER=LIB_ROOT;

CREATE PLUGGABLE DATABASE AS SEED ADMIN USER DBAOCM IDENTIFIED BY SENHA;

ALTER PLUGGABLE DATABASE LIB_ROOT$SEED OPEN;

ALTER PLUGGABLE DATABASE LIB_ROOT$SEED CLOSE IMMEDIATE;

ALTER PLUGGABLE DATABASE LIB_ROOT$SEED OPEN READ ONLY;

ALTER SESSION SET CONTAINER=LIB_ROOT$SEED;

desc Livro

ALTER PLUGGABLE DATABASE APPLICATION library_app SYNC;

desc Livro

ALTER SESSION SET CONTAINER=LIB_ROOT;

ALTER PLUGGABLE DATABASE LIB_ROOT$SEED CLOSE IMMEDIATE;

DROP PLUGGABLE DATABASE LIB_ROOT$SEED INCLUDING DATAFILES;

-- criacao de novo application PDB, que conterá a aplicação devido ao application seed existir

ALTER SESSION SET CONTAINER=LIB_ROOT;

CREATE PLUGGABLE DATABASE LIB_APP2 ADMIN USER DBAOCM IDENTIFIED BY SENHA;

ALTER PLUGGABLE DATABASE LIB_APP2 OPEN;

ALTER SESSION SET CONTAINER=LIB_APP2;

SET LINES 400
COL APP_NAME FOR A50
SELECT APP_NAME, APP_VERSION, APP_STATUS FROM DBA_APPLICATIONS;

SELECT * FROM Livro;

-- Atualizando a aplicacao:

ALTER SESSION SET CONTAINER=CDB$ROOT;

SHOW PDBS

ALTER SESSION SET CONTAINER=LIB_ROOT;

DESC EDITORA

ALTER PLUGGABLE DATABASE APPLICATION library_app BEGIN UPGRADE '1.0' TO '2.0';

ALTER TABLE Editora ADD Website VARCHAR2(50);

ALTER PLUGGABLE DATABASE APPLICATION library_app END UPGRADE TO '2.0';

DESC EDITORA

ALTER SESSION SET CONTAINER=CDB$ROOT;

SHOW PDBS

ALTER SESSION SET CONTAINER=LIB_ROOT$SEED;

SET LINES 400
COL APP_NAME FOR A50
SELECT APP_NAME, APP_VERSION, APP_STATUS FROM DBA_APPLICATIONS;

ALTER SESSION SET CONTAINER=LIB_APP1;

SET LINES 400
COL APP_NAME FOR A50
SELECT APP_NAME, APP_VERSION, APP_STATUS FROM DBA_APPLICATIONS;

ALTER SESSION SET CONTAINER=LIB_APP2;

SET LINES 400
COL APP_NAME FOR A50
SELECT APP_NAME, APP_VERSION, APP_STATUS FROM DBA_APPLICATIONS;

-- INSTALAÇÃO DE UMA SEGUNDA APLICAÇÃO

ALTER SESSION SET CONTAINER=LIB_ROOT;

ALTER PLUGGABLE DATABASE APPLICATION library_app2 BEGIN INSTALL '1.0'; 

CREATE TABLE Livro2 (
    ID NUMBER PRIMARY KEY,
    Titulo VARCHAR2(20),
    Autor VARCHAR2(20),
    Ano_Publicacao NUMBER,
    ISBN VARCHAR2(13)
);

CREATE TABLE Editora2 SHARING=EXTENDED DATA(
    ID NUMBER PRIMARY KEY,
    Nome VARCHAR2(20),
    Endereco VARCHAR2(50)
);

CREATE TABLE Cidade2 SHARING=DATA(
    ID NUMBER PRIMARY KEY,
    Nome VARCHAR2(50),
    Estado VARCHAR2(30)
);

ALTER PLUGGABLE DATABASE APPLICATION library_app2 END INSTALL '1.0'; 

ALTER SESSION SET CONTAINER=LIB_APP1;

SET LINES 400
COL APP_NAME FOR A50
SELECT APP_NAME, APP_VERSION, APP_STATUS FROM DBA_APPLICATIONS;

ALTER PLUGGABLE DATABASE APPLICATION ALL SYNC;

SET LINES 400
COL APP_NAME FOR A50
SELECT APP_NAME, APP_VERSION, APP_STATUS FROM DBA_APPLICATIONS;

ALTER SESSION SET CONTAINER=LIB_APP2;

SET LINES 400
COL APP_NAME FOR A50
SELECT APP_NAME, APP_VERSION, APP_STATUS FROM DBA_APPLICATIONS;

ALTER PLUGGABLE DATABASE APPLICATION ALL SYNC;

SET LINES 400
COL APP_NAME FOR A50
SELECT APP_NAME, APP_VERSION, APP_STATUS FROM DBA_APPLICATIONS;

-- PATCH DE APLICAÇÃO

ALTER SESSION SET CONTAINER=LIB_ROOT;

ALTER PLUGGABLE DATABASE APPLICATION library_app BEGIN PATCH 100101 MINIMUM VERSION '1.0';

DROP TABLE Editora;

ALTER TABLE Editora ADD Telefone VARCHAR2(50);

ALTER PLUGGABLE DATABASE APPLICATION library_app END PATCH 100101;

ALTER PLUGGABLE DATABASE LIB_ROOT$SEED CLOSE IMMEDIATE;

DROP PLUGGABLE DATABASE LIB_ROOT$SEED INCLUDING DATAFILES; 

CREATE PLUGGABLE DATABASE LIB_APP3 ADMIN USER DBAOCM IDENTIFIED BY SENHA;

ALTER PLUGGABLE DATABASE LIB_APP3 OPEN;

CREATE PLUGGABLE DATABASE LIB_APP4 ADMIN USER DBAOCM IDENTIFIED BY SENHA;

ALTER PLUGGABLE DATABASE LIB_APP4 OPEN;

ALTER SESSION SET CONTAINER=LIB_APP3;

SET LINES 400
COL APP_NAME FOR A50
SELECT APP_NAME, APP_VERSION, APP_STATUS FROM DBA_APPLICATIONS;

SELECT APP_NAME, PATCH_NUMBER, PATCH_STATUS FROM DBA_APP_PATCHES;

ALTER PLUGGABLE DATABASE APPLICATION library_app SYNC TO PATCH 100101;

ALTER SESSION SET CONTAINER=LIB_APP4;

ALTER PLUGGABLE DATABASE APPLICATION library_app SYNC TO '1.0';

SELECT APP_NAME, APP_VERSION, APP_STATUS FROM DBA_APPLICATIONS;

ALTER PLUGGABLE DATABASE APPLICATION ALL SYNC;

SELECT APP_NAME, APP_VERSION, APP_STATUS FROM DBA_APPLICATIONS;

SELECT APP_NAME, PATCH_NUMBER, PATCH_STATUS FROM DBA_APP_PATCHES;

ALTER SESSION SET CONTAINER=LIB_ROOT;

SELECT PDB_NAME, APP_NAME, APP_VERSION, APP_STATUS FROM DBA_APP_PDB_STATUS A  JOIN DBA_PDBS P ON A.CON_UID = P.CON_UID;

-- PARA DESINSTALAR:

ALTER SESSION SET CONTAINER=LIB_ROOT;

SET LINES 400
COL APP_NAME FOR A50
SELECT APP_NAME, VERSION_NUMBER, PATCH_NUMBER, APP_STATEMENT FROM DBA_APP_STATEMENTS;

ALTER PLUGGABLE DATABASE APPLICATION library_app BEGIN UNINSTALL; 

DROP TABLE Livro;

DROP TABLE Editora;

ALTER PLUGGABLE DATABASE APPLICATION library_app END UNINSTALL;

SELECT APP_NAME, VERSION_NUMBER, PATCH_NUMBER, APP_STATEMENT FROM DBA_APP_STATEMENTS;

COL OBJECT_NAME FOR A30
SELECT OBJECT_NAME, OBJECT_TYPE, APP_NAME FROM DBA_OBJECTS O
JOIN DBA_APPLICATIONS A  ON A.APP_ID = O.CREATED_APPID WHERE APPLICATION='Y';

DROP TABLE Cidade;

ALTER PLUGGABLE DATABASE APPLICATION library_app END UNINSTALL;



ALTER SESSION SET CONTAINER=LIB_APP1;

SET LINES 400
COL APP_NAME FOR A50
SELECT APP_NAME, APP_VERSION, APP_STATUS FROM DBA_APPLICATIONS;

ALTER PLUGGABLE DATABASE APPLICATION ALL SYNC;

SET LINES 400
COL APP_NAME FOR A50
SELECT APP_NAME, APP_VERSION, APP_STATUS FROM DBA_APPLICATIONS;

ALTER SESSION SET CONTAINER=LIB_APP2;

SET LINES 400
COL APP_NAME FOR A50
SELECT APP_NAME, APP_VERSION, APP_STATUS FROM DBA_APPLICATIONS;

ALTER PLUGGABLE DATABASE APPLICATION ALL SYNC;

SET LINES 400
COL APP_NAME FOR A50
SELECT APP_NAME, APP_VERSION, APP_STATUS FROM DBA_APPLICATIONS;

-- Container Maps


-- criacao dos pdbs

CREATE PLUGGABLE DATABASE regions AS APPLICATION CONTAINER ADMIN USER dbaocm IDENTIFIED BY senha;

ALTER PLUGGABLE DATABASE regions OPEN;

ALTER SESSION SET CONTAINER=regions;

CREATE PLUGGABLE DATABASE amer_pdb ADMIN USER dbaocm IDENTIFIED BY senha;
CREATE PLUGGABLE DATABASE euro_pdb ADMIN USER dbaocm IDENTIFIED BY senha;
CREATE PLUGGABLE DATABASE asia_pdb ADMIN USER dbaocm IDENTIFIED BY senha;

ALTER PLUGGABLE DATABASE ALL OPEN;

COL PDB_NAME FOR A20
SELECT PDB_NAME, APPLICATION_ROOT, APPLICATION_PDB FROM DBA_PDBS;

-- container map

ALTER SESSION SET CONTAINER=regions;

ALTER PLUGGABLE DATABASE APPLICATION my_container_map BEGIN INSTALL '1.0';

-- CRIACAO DE TABELA METADATA LINKED

CREATE TABLE countries_mlt SHARING=METADATA (
  region    VARCHAR2(30),
  cname     VARCHAR2(30));

-- CRIACAO DA MAP TABLE

CREATE TABLE pdb_map_tbl (cname VARCHAR2(30) NOT NULL)
  PARTITION BY LIST (cname) (
    PARTITION amer_pdb VALUES ('US','MEXICO','CANADA'),
    PARTITION euro_pdb VALUES ('UK','FRANCE','GERMANY'),
    PARTITION asia_pdb VALUES ('INDIA','CHINA','JAPAN'));

-- SETAMOS CONTAINER_MAP PARA O MAP OBJECT

ALTER PLUGGABLE DATABASE SET CONTAINER_MAP='pdb_map_tbl';

-- HABILITAMOS O CONTAINER MAP PARA A TABELA METADATA LINKED

ALTER TABLE countries_mlt ENABLE CONTAINER_MAP;

-- HABILITAMOS A CLAUSULA CONTAINERS POR PADRAO

ALTER TABLE countries_mlt ENABLE CONTAINERS_DEFAULT;

ALTER PLUGGABLE DATABASE APPLICATION my_container_map END INSTALL '1.0';


ALTER SESSION SET CONTAINER=amer_pdb;

ALTER PLUGGABLE DATABASE APPLICATION my_container_map SYNC;

ALTER SESSION SET CONTAINER=euro_pdb;

ALTER PLUGGABLE DATABASE APPLICATION my_container_map SYNC;

ALTER SESSION SET CONTAINER=asia_pdb;

ALTER PLUGGABLE DATABASE APPLICATION my_container_map SYNC;


ALTER SESSION SET CONTAINER=amer_pdb;

INSERT INTO countries_mlt VALUES ('OKLAHOMA', 'US');
INSERT INTO countries_mlt VALUES ('YUCATAN', 'MEXICO');
INSERT INTO countries_mlt VALUES ('ONTARIO', 'CANADA');
INSERT INTO countries_mlt VALUES ('YAGAMATA', 'JAPAN');
INSERT INTO countries_mlt VALUES ('BREMEN', 'GERMANY');
COMMIT;

ALTER SESSION SET CONTAINER=euro_pdb;

INSERT INTO countries_mlt VALUES ('LEINSTER', 'UK');
INSERT INTO countries_mlt VALUES ('LORRAINE', 'FRANCE');
INSERT INTO countries_mlt VALUES ('BREMEN', 'GERMANY');
INSERT INTO countries_mlt VALUES ('OKLAHOMA', 'US');
INSERT INTO countries_mlt VALUES ('YAGAMATA', 'JAPAN');
COMMIT;

ALTER SESSION SET CONTAINER=asia_pdb;

INSERT INTO countries_mlt VALUES ('ODISHA', 'INDIA');
INSERT INTO countries_mlt VALUES ('HUNAN', 'CHINA');
INSERT INTO countries_mlt VALUES ('YAGAMATA', 'JAPAN');
INSERT INTO countries_mlt VALUES ('OKLAHOMA', 'US');
INSERT INTO countries_mlt VALUES ('BREMEN', 'GERMANY');
COMMIT;


ALTER SESSION SET CONTAINER=regions;

SHOW PDBS

SELECT * FROM countries_mlt WHERE CON_ID = 5;

SELECT * FROM countries_mlt WHERE CON_ID = 10;

SELECT * FROM countries_mlt WHERE CON_ID = 11;

SELECT * FROM countries_mlt;

SELECT * FROM CONTAINERS(countries_mlt);

col pdb_name for a15
SELECT region, cname, pdb_name FROM countries_mlt c JOIN dba_pdbs p ON c.con_id = p.pdb_id;

COL TABLE_NAME FOR A25
SELECT TABLE_NAME, CONTAINERS_DEFAULT, CONTAINER_MAP FROM DBA_TABLES WHERE TABLE_NAME IN ('COUNTRIES_MLT', 'PDB_MAP_TBL');




-- Gerenciando Service Names de PDBs


COL NAME FOR A20
COL PDB FOR A20
SELECT NAME, PDB FROM cdb_services;

COL NAME FOR A20
COL PDB FOR A20
SELECT NAME, PDB FROM V$SERVICES;


-- adicionar tnsnames apontando para este servico

vi $ORACLE_HOME/network/admin/tnsnames.ora

SERV =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = ol7-grid.localdomain)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = my_service.localdomain)
    )
  )

tnsping serv

sqlplus / as sysdba

ALTER SESSION SET CONTAINER=orclpdb;

create user dbaocm identified by senha;

GRANT DBA, CONNECT, RESOURCE TO DBAOCM;


-- DBMS_SERVICE

-- adicionar servico

sqlplus / as sysdba

ALTER SESSION SET CONTAINER=orclpdb;

COL NAME FOR A20
COL PDB FOR A20
COL NETWORK_NAME FOR A35
SELECT NAME, NETWORK_NAME, PDB FROM dba_services;

BEGIN
  DBMS_SERVICE.CREATE_SERVICE(
    service_name => 'my_service',
    network_name => 'my_service.localdomain');
END;
/

EXEC DBMS_SERVICE.START_SERVICE('my_service');

!lsnrctl status

-- adicionar tnsnames apontando para este servico

vi $ORACLE_HOME/network/admin/tnsnames.ora

SERV =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = dbaocm.localdomain)(PORT = 1521))
    (CONNECT_DATA =sqlplus / as
      (SERVER = DEDICATED)
      (SERVICE_NAME = my_service.localdomain)
    )
  )

sqlplus / as sysdba

conn dbaocm/senha@serv

show con_name

-- parar o servico

conn / as sysdba

ALTER SESSION SET CONTAINER=orclpdb;

EXEC DBMS_SERVICE.STOP_SERVICE('my_service');

-- excluir o servico

EXEC DBMS_SERVICE.DELETE_SERVICE('my_service');
