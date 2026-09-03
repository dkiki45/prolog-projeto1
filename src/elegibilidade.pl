% ==============================================================================
% CAMADA 2: REGRAS DE ELEGIBILIDADE
% Arquivo: elegibilidade.pl
% ==============================================================================

% Carrega a base de fatos
:- consult('curriculum.pl').

% ------------------------------------------------------------------------------
% prerequisitos_ok(Aluno, Disciplina)
% Verdadeiro se TODOS os pré-requisitos diretos da disciplina já foram cursados pelo aluno.
% Uso exigido do forall/2.
% ------------------------------------------------------------------------------
prerequisitos_ok(Aluno, Disciplina) :-
    % Para todo X que é pré-requisito da Disciplina, garanta que o Aluno cursou X.
    forall(prerequisito(Disciplina, PreReq), cursou(Aluno, PreReq)).

% ------------------------------------------------------------------------------
% pode_cursar(Aluno, Disciplina)
% Verdadeiro se a disciplina existe, o aluno AINDA NÃO cursou, e tem os pré-requisitos.
% Uso exigido de negação por falha (\+).
% ------------------------------------------------------------------------------
pode_cursar(Aluno, Disciplina) :-
    % 1. Instancia a variável Disciplina (Evita a armadilha da negação com variável livre)
    disciplina(Disciplina, _, _, _),
    
    % 2. Garante que o aluno ainda não cursou (Negação por falha)
    \+ cursou(Aluno, Disciplina),
    
    % 3. Verifica se os pré-requisitos estão cumpridos
    prerequisitos_ok(Aluno, Disciplina).

% ------------------------------------------------------------------------------
% disciplinas_liberadas(Aluno, Lista)
% Retorna uma lista com todas as disciplinas que o aluno pode cursar agora.
% Uso de setof/3 para garantir que não há duplicatas e a lista venha ordenada.
% ------------------------------------------------------------------------------
disciplinas_liberadas(Aluno, Lista) :-
    % Tenta encontrar o conjunto de disciplinas. Se falhar (vazio), retorna []
    ( setof(D, pode_cursar(Aluno, D), Lista) -> true ; Lista = [] ).

% ------------------------------------------------------------------------------
% disciplinas_pendentes(Aluno, Lista)
% Retorna todas as disciplinas OBRIGATÓRIAS ainda não cursadas, 
% independentemente de elegibilidade (não olha pré-requisito).
% ------------------------------------------------------------------------------
disciplinas_pendentes(Aluno, Lista) :-
    % Instancia D como obrigatória, garante que não cursou, e coleta no setof
    ( setof(D, (disciplina(D, obrigatoria, _, _), \+ cursou(Aluno, D)), Lista) -> true ; Lista = [] ).

% ------------------------------------------------------------------------------
% creditos_cursados(Aluno, Total)
% Soma os créditos de tudo que o aluno já cursou.
% Uso de findall/3 para coletar os valores numéricos.
% ------------------------------------------------------------------------------
creditos_cursados(Aluno, Total) :-
    % Encontra a disciplina D que o aluno cursou e extrai a quantidade de C (Créditos)
    findall(C, (cursou(Aluno, D), disciplina(D, _, C, _)), ListaCreditos),
    
    % Predicado nativo do SWI-Prolog para somar listas numéricas
    sum_list(ListaCreditos, Total).