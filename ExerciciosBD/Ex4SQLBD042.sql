drop table empregado;
drop table departamento;
drop table projeto;
drop table trabalhando;
drop table dependente;
drop table deploc;

create table empregado  (
    ident int(11),
    nome character varying(100) NOT NULL,
    salario FLOAT NOT NULL,
    endereco character varying(255) NOT NULL,
    sexo char(1) NOT NULL DEFAULT 'M' CHECK ((sexo = 'M') OR (sexo = 'F')),
    data_nasc DATE NOT NULL CHECK (nascimento <= NOW()),
    q
);

create table departamento (
    num INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    ident_ger INT NOT NULL REFERENCES empregado (ident), 
    PRIMARY KEY (num)
);
