create or replace function km2mi (float) returns float as
	'select $1 * 0.6'
language 'sql';
select km2mi(20);

create or replace function ymd2dma_1 (timestamp) returns text as $$
	select ltrim(to_char(date_part('day', $1), '00')) || '/' || ltrim(to_char(date_part('month', $1), '00')) || '/' || ltrim(to_char(date_part('year', $1), '0000'));
$$ language 'sql';
select ymd2dma_1(current_date);

create or replace function ymd2dma_2 (timestamp) returns text as $$
begin
	return ltrim(to_char(date_part('day', $1), '00')) || '/' || ltrim(to_char(date_part('month', $1), '00')) || '/' || ltrim(to_char(date_part('year', $1), '0000'));
end;
$$ language 'plpgsql';
select ymd2dma_2(current_date);

create or replace function validacpf(cpf char(11)) returns boolean as $$
declare
	d integer;
	i integer;
begin
	if (length(trim(cpf)) != 11) then
		return false;
	end if;
	for i in 1..11 loop
		if ((substring(cpf, i, 1) < '0') or (substring(cpf, i, 1) > '9')) then
			return false;
		end if;
	end loop;
	if ((cpf = '00000000000') or (cpf = '11111111111') or (cpf = '22222222222') or (cpf = '33333333333') or
		(cpf = '44444444444') or (cpf = '55555555555') or (cpf = '66666666666') or (cpf = '77777777777') or
		(cpf = '88888888888') or (cpf = '99999999999')) then
		return false;
	end if;
	d := 0;
	for i in reverse 9..1 loop
		d := d + (11 - i) * (substring(cpf, i, 1)::integer);
	end loop;
	d := 11 - (d % 11);
	if (d > 9) then
		d := 0;
	end if;
	if (d != (substring(cpf, 10, 1)::integer)) then
		return false;
	end if;
	d := 0;
	for i in reverse 10..1 loop
		d := d + (12 - i) * (substring(cpf, i, 1)::integer);
	end loop;
	d := 11 - (d % 11);
	if (d > 9) then
		d := 0;
	end if;
	if (d != (substring(cpf, 11, 1)::integer)) then
		return false;
	end if;
	return true;
end;
$$ language 'plpgsql';
select validacpf('12345678901');
select validacpf('00276953010');
create table pessoa (cpf char(11) not null check (validacpf(cpf)), nome varchar(100) not null);
insert into pessoa values ('12345678901', 'joao silva');
insert into pessoa values ('00276953010', 'maria silva');

create table departamento (
	codigo integer not null primary key,
	nome varchar(50) not null
);
create table funcionario (
	codigo integer not null primary key,
	nome varchar(50),
	departamento integer not null references departamento(codigo),
	salario real check (salario > 0)
);
insert into departamento values (1, 'Depto 1');
insert into departamento values (2, 'Depto 2');
insert into departamento values (3, 'Depto 3');
insert into funcionario values (1, 'Funcionario 1', 1, 1000);
insert into funcionario values (2, 'Funcionario 2', 1, 1500);
insert into funcionario values (3, 'Funcionario 3', 2, 900);
insert into funcionario values (4, 'Funcionario 4', 3, 5000);
insert into funcionario values (5, 'Funcionario 5', 3, 6000);

select max(salario) from funcionario where departamento = 1;

create function calculamaiorsalario(codigo integer) returns real as $$
declare
	r_funcionario record;
	salario real;
begin
	salario := 0;
	for r_funcionario in select * from funcionario loop
		raise notice 'funcionario: %, %, %, %', r_funcionario.codigo, r_funcionario.nome, r_funcionario.departamento, r_funcionario.salario;
		if (r_funcionario.departamento = codigo) and (r_funcionario.salario > salario) then
			salario := r_funcionario.salario;
		end if;
	end loop;
	return salario;
end;
$$ language 'plpgsql';
select calculamaiorsalario(1);

select departamento.nome, avg(salario) as salariomedio from departamento join funcionario on funcionario.departamento = departamento.codigo group by departamento.nome order by departamento.nome;

create type salariomedio as (departamento varchar(50), salariomedio real);
create function calculasalariomedio() returns setof salariomedio as $$
declare
	r_departamento record;
	r_funcionario record;
	r_salariomedio salariomedio%rowtype;
	soma real;
	quantidadefuncionarios integer;
begin
	for r_departamento in select * from departamento loop
		raise notice 'departamento: %, %', r_departamento.codigo, r_departamento.nome;
		quantidadefuncionarios := 0;
		soma := 0;
		for r_funcionario in select * from funcionario loop
			if (r_funcionario.departamento = r_departamento.codigo) then
				raise notice 'funcionario: %, %, %, %', r_funcionario.codigo, r_funcionario.nome, r_funcionario.departamento, r_funcionario.salario;
				soma := soma + r_funcionario.salario;
				quantidadefuncionarios := quantidadefuncionarios + 1;
			end if;
		end loop;
		r_salariomedio.departamento := r_departamento.nome;
		r_salariomedio.salariomedio := soma/quantidadefuncionarios;
		return next r_salariomedio;
	end loop;
	return;
end;
$$ language 'plpgsql';
select * from calculasalariomedio();

Uma função de gatilho deve retornar nulo ou um registro possuindo a mesma estrutura da tabela para a qual foi disparado. Se um gatilho disparado BEFORE retornar nulo, não será executado o gatilho AFTER, e não ocorrerá o INSERT/UPDATE/DELETE para esta linha. Retornar um registro diferente de NEW altera a linha que será inserida ou atualizada (não tem efeito no DELETE). É possível substituir valores diretamente em NEW e retornar um NEW modificado. O retorno de um gatilho disparado AFTER é sempre ignorado.

CREATE TABLE empregados (
   codigo  serial  PRIMARY KEY,
   nome    text,
   salario float
);

CREATE TABLE empregados_auditoria (
   operacao     char(1)   NOT NULL,
   usuario      text      NOT NULL,
   data         timestamp NOT NULL,
   codigo       integer   NOT NULL,
   coluna       text,
   valor_antigo text,
   valor_novo   text
);

create or replace function trigger_before() returns trigger as $$
begin
    if (new.nome is null) then
        raise exception 'o nome do empregado não pode ser nulo';
    end if;
    if (new.salario is null) then
        raise exception '% não pode ter um salário nulo', new.nome;
    end if;
    if (new.salario < 0) then
        raise exception '% não pode ter um salário negativo', new.nome;
    end if;
    if (tg_op = 'INSERT') then
        if (new.codigo is not null) then
            raise notice 'o código % do empregado não será utilizado', new.codigo;
			new.codigo := nextval('empregados_codigo_seq'::regclass);
        end if;
    else
        if (new.codigo <> old.codigo) then
            raise exception 'não é permitido atualizar o código do empregado';
        end if;
    end if;
    return new;
end;
$$ language plpgsql;

create trigger trigger_before before insert or update on empregados for each row execute procedure trigger_before();

create or replace function trigger_after() returns trigger as $$
begin
    if (tg_op = 'INSERT') then
        insert into empregados_auditoria select 'i', current_user, current_timestamp, new.codigo, 'codigo', null, new.codigo;
        insert into empregados_auditoria select 'i', current_user, current_timestamp, new.codigo, 'nome', null, new.nome;
        insert into empregados_auditoria select 'i', current_user, current_timestamp, new.codigo, 'salario', null, new.salario;
    else
        if (tg_op = 'UPDATE') then
            if (new.nome <> old.nome) then
                insert into empregados_auditoria select 'u',current_user, current_timestamp, new.codigo, 'nome', old.nome, new.nome;
            end if;
            if (new.salario <> old.salario) then
                insert into empregados_auditoria select 'u',current_user, current_timestamp, new.codigo, 'salario', old.salario, new.salario;
            end if;
        else
            insert into empregados_auditoria select 'd',current_user, current_timestamp, old.codigo, null, null, null;
        end if;
    end if;
    return null;
end;
$$ language plpgsql;

create trigger trigger_after after insert or update or delete on empregados for each row execute procedure trigger_after();

