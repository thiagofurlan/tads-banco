drop table emprestimo;
drop table deposito;
drop table cliente;
drop table agencia;

create table agencia (
    nome_agencia varchar(30),
    ativos float,
    cidade_agencia varchar(30)
);

insert into agencia values ('Downtown',9000000,'Brooklyn');
insert into agencia values ('Redwood',2100000,'Palo Alto');
insert into agencia values ('Perryridge',1700000,'Horseneck');
insert into agencia values ('Mianus',400000,'Horseneck');
insert into agencia values ('Round Hill',8000000,'Horseneck');
insert into agencia values ('Pownal',300000,'Bennington');
insert into agencia values ('North Town',3700000,'Rye');
insert into agencia values ('Brighton',7100000,'Brooklyn');

create table cliente (
    nome_cliente varchar(30),
    rua varchar(30),
    cidade_cliente varchar(30)
);

insert into cliente values ('Jones','Main','Harrison');
insert into cliente values ('Smith','North','Rye');
insert into cliente values ('Hayes','Main','Harrison');
insert into cliente values ('Curry','North','Rye');
insert into cliente values ('Lindsay','Park','Pittsfield');
insert into cliente values ('Turner','Putnam','Stamford');
insert into cliente values ('William','Nassau','Princeton');
insert into cliente values ('Adams','Spring','Pittsfield');
insert into cliente values ('Johnson','Alma','Palo Alto');
insert into cliente values ('Glenn','Sand Hill','Wooside');
insert into cliente values ('Brooks','Senator','Brooklyn');
insert into cliente values ('Green','Walnut','Stamford');

create table deposito (
    nome_agencia varchar(30),
    numero_conta int,
    nome_cliente varchar(30),
    saldo real
);

insert into deposito values ('Downtown',101,'Johnson',500);
insert into deposito values ('Mianus',215,'Smith',700);
insert into deposito values ('Perryridge',102,'Hayes',400);
insert into deposito values ('Round Hill',305,'Turner',350);
insert into deposito values ('Perryridge',201,'William',900);
insert into deposito values ('Redwood',222,'Lindsay',700);
insert into deposito values ('Brighton',217,'Green',750);
insert into deposito values ('Downtown',105,'Green',850);

create table emprestimo (
    nome_agencia varchar(30),
    numero_emprestimo int,
    nome_cliente varchar(30),
    quantia real
);

insert into emprestimo values ('Downtown',17,'Jones',1000);
insert into emprestimo values ('Redwood',23,'Smith',2000);
insert into emprestimo values ('Perryridge',15,'Hayes',1500);
insert into emprestimo values ('Downtown',14,'Jackson',1500);
insert into emprestimo values ('Mianus',93,'Curry',500);
insert into emprestimo values ('Round Hill',11,'Turner',900);
insert into emprestimo values ('Pownal',29,'William',1200);
insert into emprestimo values ('North Town',16,'Adams',1300);
insert into emprestimo values ('Downtown',18,'Johnson',2000);
insert into emprestimo values ('Perryridge',25,'Glenn',2500);
insert into emprestimo values ('Brighton',10,'Brooks',2200);
