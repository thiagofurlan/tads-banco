--create database emprego;

drop table if exists experienciaconhecimento;
drop table if exists experiencia;
drop table if exists cursoconhecimento;
drop table if exists curso;
drop table if exists tituloconhecimento;
drop table if exists titulo;
drop table if exists vagaconhecimento;
drop table if exists vagatitulo;
drop table if exists vaga;
drop table if exists empresa;
drop table if exists candidato;


create table empresa (
    cnpj varchar(14) not null primary key,
    nome varchar(100) not null
);

create table candidato (
    cpf varchar(11) not null primary key,
    nome varchar(100) not null,
    nascimento date not null,
    genero char(1) not null,
    pretensaosalarial real not null,
    visivel boolean not null
);

create table experiencia (
    codigo serial not null primary key,
    cpf varchar(11) not null references candidato(cpf),
    empresa varchar(50) not null,
    funcao varchar(100) not null,
    inicio date not null,
    fim date not null,
    cargasemanal integer not null
);

create table experienciaconhecimento (
    id serial not null primary key,
    experiencia integer not null references experiencia(codigo),
    descricao varchar(255)
);

create table curso (
    codigo serial not null primary key,
    cpf varchar(11) not null references candidato(cpf),
    inicio date not null,
    fim date not null,
    cargahoraria real not null,
    descricao varchar(255) not null,
    instituicao varchar(100) not null
);

create table cursoconhecimento (
    id serial not null primary key,
    curso integer not null references curso(codigo),
    descricao varchar(255) not null
);

create table titulo (
    codigo serial not null primary key,
    cpf varchar(11) not null references candidato(cpf),
    inicio date not null,
    fim date not null,
    descricao varchar(255) not null,
    instituicao varchar(100) not null
);

create table tituloconhecimento (
    id serial not null primary key,
    titulo integer not null references titulo(codigo),
    descricao varchar(255) not null
);

-- voltar aqui
create table vaga (
    codigo serial not null primary key,
    empresa varchar(14) not null references empresa(cnpj),
    tempoexperiencia integer not null,
    minidade integer not null,
    maxidade integer not null,
    genero char(1) default null,
    salario real not null,
    data date not null default now()::date
);

create table vagatitulo (
    id serial not null primary key,
    vaga integer not null references vaga(codigo),
    descricao varchar(255) not null
);

create table vagaconhecimento (
    codigo serial not null primary key,
    vaga integer not null references vaga(codigo),
    descricao varchar(255)
);

-- Incluir 2 novas vagas de emprego para a empresa XYZ SA com salário de R$2.500,00 e os requisitos a) titulação em Tecnologia
-- em Análise e Desenvolvimento de Sistemas, b) conhecimentos necessários de PostgreSQL, Java, HTML, CSS, Javascript, MVC e
-- língua inglesa, c) tempo de experiência mínimo de 1 ano e d) idade máxima de 30 anos.

-- 2.1
insert into empresa (nome, cnpj) values ('XYZ SA', '19667480000177');

-- testes
insert into vaga (empresa, tempoexperiencia, minidade, maxidade, genero, salario, data) values ('19667480000177', 1, 0, 30, null, 2500, '2018-10-01');
insert into vaga (empresa, tempoexperiencia, minidade, maxidade, genero, salario, data) values ('19667480000177', 1, 0, 30, null, 2500, '2018-10-06');
insert into vaga (empresa, tempoexperiencia, minidade, maxidade, genero, salario, data) values ('19667480000177', 1, 0, 30, null, 2500, '2018-09-01');
-- fim testes

insert into vaga (empresa, tempoexperiencia, minidade, maxidade, genero, salario) values ('19667480000177', 1, 0, 30, null, 2500);
-- considerando que o banco emprego está zerado, o insert da primeira vaga retornará o código 1
insert into vagatitulo (vaga, descricao) values (1, 'Tecnologia em Análise e Desenvolvimento de Sistemas');
insert into vagaconhecimento (vaga, descricao) values (1, 'PostgreSQL, Java, HTML, CSS, Javascript, MVC e língua inglesa');

insert into vaga (empresa, tempoexperiencia, minidade, maxidade, genero, salario) values ('19667480000177', 1, 0, 30, null, 2500);
-- considerando que RETURNS código do insert da segunda vaga retornará o código 2
insert into vagatitulo (vaga, descricao) values (2, 'Tecnologia em Análise e Desenvolvimento de Sistemas');
insert into vagaconhecimento (vaga, descricao) values (2, 'PostgreSQL, Java, HTML, CSS, Javascript, MVC e língua inglesa');







-- 2.2
insert into candidato (cpf, nome, nascimento, genero, pretensaosalarial, visivel) values ('22222222222', 'Fulano de Tal', '1990-06-10', 'M', 3000, true);

insert into titulo (cpf, inicio, fim, descricao, instituicao) values ('22222222222', '2005-01-01', '2008-12-01', 'Técnico em Informática para Internet', 'IFRS campus Rio Grande');
insert into tituloconhecimento (titulo, descricao) values (1, 'HTML, CSS, Javascript e PHP');

insert into titulo (cpf, inicio, fim, descricao, instituicao) values ('22222222222', '2009-01-01', '2012-06-01', 'Tecnologia em Análise em Desenvolvimento de Sistemas', 'IFRS campus Rio Grande');
insert into tituloconhecimento (titulo, descricao) values (2, 'Java, JavaEE, PostgreSQL, MySQL, HTML, CSS, Javascript, MVC, SOAP e REST');

insert into curso (cpf, inicio, fim, cargahoraria, descricao, instituicao) values ('22222222222', '2011-03-01', '2011-05-01', 80, 'Programação para Android', 'KLM Cursos');
insert into cursoconhecimento (curso, descricao) values (1, 'Java, Android, PhoneGap e PWA');

insert into curso (cpf, inicio, fim, cargahoraria, descricao, instituicao) values ('22222222222', '2012-07-01', '2012-10-01', 120, 'Programação em .NET', 'NOP Treinamentos');
insert into cursoconhecimento (curso, descricao) values (2, '.NET, C# e F#');

insert into curso (cpf, inicio, fim, cargahoraria, descricao, instituicao) values ('22222222222', '2015-01-01', '2015-12-01', 180, 'Inglês Intermediário', 'ABC Idiomas');
insert into cursoconhecimento (curso, descricao) values (3, 'língua inglesa');

insert into experiencia (cpf, empresa, funcao, inicio, fim, cargasemanal) values ('22222222222', 'ABC Digital', 'programador júnior', '2012-07-01', '2012-12-01', 24);
insert into experienciaconhecimento (experiencia, descricao) values (1, 'HTML, CSS, Javascript, PHP e MySQL');

insert into experiencia (cpf, empresa, funcao, inicio, fim, cargasemanal) values ('22222222222', 'DEF Tecnologias', 'programador júnior', '2013-01-01', '2014-01-01', 24);
insert into experienciaconhecimento (experiencia, descricao) values (2, 'Java, PostgreSQL e MySQL');

insert into experiencia (cpf, empresa, funcao, inicio, fim, cargasemanal) values ('22222222222', 'DEF Tecnologias', 'programador pleno', '2014-02-01', '2015-01-01', 40);
insert into experienciaconhecimento (experiencia, descricao) values (3, 'Java, PostgreSQL, MySQL e Android');


-- 2.3
-- Mostrar um gráfico de barras com a quantidade mensal absoluta de vagas a preencher na empresa XYZ SA nos últimos 12 meses, como no exemplo abaixo.

select repeat('*', tmp2.c::int) as grafico from (select count(*) as c from (select * from vaga join empresa on vaga.empresa = empresa.cnpj where empresa.nome ILIKE '%XYZ SA%' and vaga.data between (now() - interval '12 months') and now()) as tmp1 group by date_part('month', tmp1.data)) as tmp2;


--2.4
--Mostrar os candidatos que satisfazem todos os requisitos para uma vaga da questão 2.1.

select descricao from vagaconhecimento where vagaconhecimento. 


(select 
    candidato.nome,
    candidato.cpf,
    experienciaconhecimento.descricao as edesc,
    cursoconhecimento.descricao as cdesc,
    tituloconhecimento.descricao as tdesc
    from candidato
    join experiencia on candidato.cpf = experiencia.cpf
    join experienciaconhecimento on experiencia.codigo = experienciaconhecimento.experiencia
    join curso on curso.cpf = candidato.cpf
    join cursoconhecimento on curso.codigo = cursoconhecimento.curso
    join titulo on titulo.cpf = candidato.cpf
    join tituloconhecimento on titulo.codigo = tituloconhecimento.titulo) as tmp;
    
