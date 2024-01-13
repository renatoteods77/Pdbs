# Pdbs
A arquitetura multitenante do Oracle permite que um banco de dados Oracle funcione como um banco de dados contêiner (CDB). A partir do Oracle Database 21c, um banco de dados contêiner é a única arquitetura suportada. Nos lançamentos anteriores, o Oracle suportava bancos de dados não contêineres (non-CDBs).
Sobre Contêineres em um CDB O Contêiner Raiz e o Contêiner Sistema AO

Um contêiner é uma coleção de esquemas, objetos e estruturas relacionadas em um banco de dados contêiner (CDB) do Oracle. Dentro de um CDB, cada contêiner tem um ID e nome únicos.

Um CDB inclui zero, um ou muitos bancos de dados plugáveis (PDBs) e contêineres de aplicativos opcionais. Um PDB é uma coleção portátil de esquemas, objetos de schema e objetos não schema que aparecem para um cliente Oracle Net como um banco de dados separado. Um contêiner de aplicativos é uma opção, coleção de usuários criada pelo usuário que armazena dados e metadados para um ou mais aplicativos back-end. Um CDB inclui zero ou mais contêineres de aplicativos.
Todo CDB tem os seguintes contêineres:

Exatamente um contêiner raiz do CDB (também chamado simplesmente de raiz)

O contêiner raiz do CDB é uma coleção de esquemas, objetos de schema e objetos não schema aos quais todos os PDBs pertencem (consulte "CDBs e PDBs"). A raiz armazena metadados Oracle-fornecidos e usuários comuns. Um exemplo de metadados é o código-fonte para pacotes PL/SQL Oracle-fornecidos. Um usuário comum é um usuário de banco de dados conhecido em todos os contêineres. O contêiner raiz é nomeado CDB$ROOT.

Exatamente um contêiner de sistema

O contêiner de sistema inclui a raiz CDB e todos os PDBs no CDB. Portanto, o contêiner de sistema é o contêiner lógico para o CDB em si.

Zero ou mais contêineres de aplicativos

Um contêiner de aplicativos consiste exatamente em uma raiz de aplicativos e os PDBs conectados a essa raiz. Enquanto o contêiner de sistema contém a raiz CDB e todos os PDBs dentro do CDB, um contêiner de aplicativos inclui apenas os PDBs conectados à raiz do aplicativo. Uma raiz de aplicativos pertence à raiz CDB e a nenhum outro contêiner.

Zero ou mais PDBs criados pelo usuário

Um PDB contém os dados e código necessários para um conjunto específico de recursos (consulte "PDBs"). Por exemplo, um PDB pode dar suporte a um aplicativo específico, como um aplicativo de recursos humanos ou vendas. Nenhum PDBs existem na criação do CDB. Você adiciona PDBs com base em seus requisitos comerciais.

Um PDB pertence exatamente a zero ou um contêiner de aplicativos. Se um PDB pertencer a um contêiner de aplicativos, então é um PDB de aplicativo. Por exemplo, os PDBs de aplicativos cust1_pdb e cust2_pdb podem pertencer ao contêiner de aplicativos saas_sales_ac, neste caso, eles pertencem a nenhum outro contêiner de aplicativos. Uma semente de PDB é um PDB opcional de aplicativo que atua como um modelo de PDB criado pelo usuário, o que permite criar novos PDBs de aplicativos rapidamente.

Exatamente uma semente PDB

A semente PDB é um modelo Oracle-fornecido que o CDB pode usar para criar novos PDBs. A semente PDB é nomeada PDB$SEED. Você não pode adicionar ou modificar objetos nesta semente PDB.
