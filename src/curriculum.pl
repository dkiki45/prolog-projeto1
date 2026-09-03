:- encoding(utf8).

% ==============================================================================
% CAMADA 1: BASE DE FATOS
% ==============================================================================

% ------------------------------------------------------------------------------
% 1. DISCIPLINAS
% Formato: disciplina(Nome, Tipo, Creditos, Semestre).
% Tipo deve ser 'obrigatoria' ou 'eletiva'.
% ------------------------------------------------------------------------------

% --- Semestre 1 ---
disciplina(fundamentos_sistemas_ciberfisicos, obrigatoria, 4, 1).
disciplina(resolucao_problemas_logica_matematica, obrigatoria, 4, 1).
disciplina(filosofia, obrigatoria, 4, 1).
disciplina(exp_criativa_navegando, obrigatoria, 6, 1).
disciplina(raciocinio_algoritmico, obrigatoria, 6, 1).

% --- Semestre 2 ---
disciplina(resolucao_problemas_discreta, obrigatoria, 4, 2).
disciplina(arquitetura_banco_dados, obrigatoria, 6, 2).
disciplina(programacao_imperativa, obrigatoria, 4, 2).
disciplina(programacao_web, obrigatoria, 4, 2).
disciplina(conectividade_sistemas_ciberfisicos, obrigatoria, 4, 2).
disciplina(etica, obrigatoria, 2, 2).

% --- Semestre 3 ---
disciplina(modelagem_fenomenos_fisicos, obrigatoria, 4, 3).
disciplina(exp_criativa_criando_solucoes, obrigatoria, 6, 3).
disciplina(programacao_orientada_objetos, obrigatoria, 6, 3).
disciplina(seguranca_informacao, obrigatoria, 4, 3).
disciplina(performance_sistemas_ciberfisicos, obrigatoria, 4, 3).
disciplina(clinica_tic, obrigatoria, 2, 3).

% --- Semestre 4 ---
disciplina(teologia_sociedade, obrigatoria, 2, 4).
disciplina(resolucao_problemas_estruturados, obrigatoria, 4, 4).
disciplina(programacao_logica_funcional, obrigatoria, 4, 4).
disciplina(big_data, obrigatoria, 4, 4).
disciplina(sistemas_operacionais, obrigatoria, 4, 4).
disciplina(redes_convergentes, obrigatoria, 4, 4).
disciplina(modelagem_sistemas_computacionais, obrigatoria, 4, 4).

% --- Semestre 5 ---
disciplina(complexidade_algoritmos, obrigatoria, 4, 5).
disciplina(metodos_quantitativos, obrigatoria, 4, 5).
disciplina(resolucao_problemas_grafos, obrigatoria, 6, 5).
disciplina(metodos_pesquisa_cientifica, obrigatoria, 4, 5).
disciplina(exp_criativa_inovando, obrigatoria, 6, 5).

% --- Semestre 6 ---
disciplina(aprendizagem_maquina, obrigatoria, 4, 6).
disciplina(inteligencia_artificial, obrigatoria, 4, 6).
disciplina(programacao_distribuida, obrigatoria, 4, 6).
disciplina(gestao_projetos, obrigatoria, 6, 6).
disciplina(pesquisa_aplicada, obrigatoria, 4, 6).
disciplina(engenharia_software, obrigatoria, 4, 6).

% --- Eletivas ---
disciplina(strategic_management, eletiva, 4, 7).
disciplina(computacao_quantica, eletiva, 4, 7).
disciplina(desenvolvimento_mobile, eletiva, 4, 7). 


% ------------------------------------------------------------------------------
% 2. PRÉ-REQUISITOS
% Formato: prerequisito(Disciplina, Prerequisito).
% ------------------------------------------------------------------------------

% Cadeia de Profundidade >= 3 (Exigência do trabalho)
% raciocinio_algoritmico -> programacao_imperativa -> programacao_orientada_objetos -> engenharia_software
prerequisito(programacao_imperativa, raciocinio_algoritmico).
prerequisito(programacao_orientada_objetos, programacao_imperativa).
prerequisito(engenharia_software, programacao_orientada_objetos).

% Outros pré-requisitos lógicos para enriquecer a base
prerequisito(arquitetura_banco_dados, raciocinio_algoritmico).
prerequisito(programacao_web, programacao_imperativa).
prerequisito(programacao_web, arquitetura_banco_dados).

prerequisito(conectividade_sistemas_ciberfisicos, fundamentos_sistemas_ciberfisicos).
prerequisito(redes_convergentes, conectividade_sistemas_ciberfisicos).
prerequisito(sistemas_operacionais, conectividade_sistemas_ciberfisicos).

% Cadeia de Profundidade 3 (nº 3): programacao_distribuida -> redes_convergentes ->
% conectividade_sistemas_ciberfisicos -> fundamentos_sistemas_ciberfisicos
prerequisito(programacao_distribuida, redes_convergentes).

prerequisito(programacao_logica_funcional, resolucao_problemas_logica_matematica).
prerequisito(resolucao_problemas_discreta, resolucao_problemas_logica_matematica).

prerequisito(big_data, arquitetura_banco_dados).
prerequisito(aprendizagem_maquina, big_data).
prerequisito(inteligencia_artificial, aprendizagem_maquina).
prerequisito(inteligencia_artificial, metodos_quantitativos).

prerequisito(complexidade_algoritmos, resolucao_problemas_estruturados).
prerequisito(resolucao_problemas_grafos, resolucao_problemas_estruturados).

% Cadeia de Profundidade 3 (nº 4): complexidade_algoritmos (ou resolucao_problemas_grafos) ->
% resolucao_problemas_estruturados -> resolucao_problemas_discreta -> resolucao_problemas_logica_matematica
prerequisito(resolucao_problemas_estruturados, resolucao_problemas_discreta).


% ------------------------------------------------------------------------------
% 3. HISTÓRICO DOS ALUNOS (CURSOU)
% Formato: cursou(Aluno, Disciplina).
% ------------------------------------------------------------------------------

% DAVID: Perfil "Ritmo Normal" (Concluiu semestres 1, 2 e 3)
cursou(david, fundamentos_sistemas_ciberfisicos).
cursou(david, resolucao_problemas_logica_matematica).
cursou(david, filosofia).
cursou(david, exp_criativa_navegando).
cursou(david, raciocinio_algoritmico).
cursou(david, resolucao_problemas_discreta).
cursou(david, arquitetura_banco_dados).
cursou(david, programacao_imperativa).
cursou(david, programacao_web).
cursou(david, conectividade_sistemas_ciberfisicos).
cursou(david, etica).
cursou(david, modelagem_fenomenos_fisicos).
cursou(david, exp_criativa_criando_solucoes).
cursou(david, programacao_orientada_objetos).
cursou(david, seguranca_informacao).
cursou(david, performance_sistemas_ciberfisicos).
cursou(david, clinica_tic).

% JOÃO: Perfil "Atrasado/Trancamento" (Fez apenas algumas matérias avulsas)
cursou(joao, fundamentos_sistemas_ciberfisicos).
cursou(joao, filosofia).
cursou(joao, raciocinio_algoritmico).
cursou(joao, etica).

% THEO: Perfil "Adiantado" (Concluiu 1 ao 5 e já fez eletivas)
cursou(theo, fundamentos_sistemas_ciberfisicos).
cursou(theo, resolucao_problemas_logica_matematica).
cursou(theo, filosofia).
cursou(theo, exp_criativa_navegando).
cursou(theo, raciocinio_algoritmico).
cursou(theo, resolucao_problemas_discreta).
cursou(theo, arquitetura_banco_dados).
cursou(theo, programacao_imperativa).
cursou(theo, programacao_web).
cursou(theo, conectividade_sistemas_ciberfisicos).
cursou(theo, etica).
cursou(theo, modelagem_fenomenos_fisicos).
cursou(theo, exp_criativa_criando_solucoes).
cursou(theo, programacao_orientada_objetos).
cursou(theo, seguranca_informacao).
cursou(theo, performance_sistemas_ciberfisicos).
cursou(theo, clinica_tic).
cursou(theo, teologia_sociedade).
cursou(theo, resolucao_problemas_estruturados).
cursou(theo, programacao_logica_funcional).
cursou(theo, big_data).
cursou(theo, sistemas_operacionais).
cursou(theo, redes_convergentes).
cursou(theo, modelagem_sistemas_computacionais).
cursou(theo, complexidade_algoritmos).
cursou(theo, metodos_quantitativos).
cursou(theo, resolucao_problemas_grafos).
cursou(theo, metodos_pesquisa_cientifica).
cursou(theo, exp_criativa_inovando).
cursou(theo, strategic_management).
cursou(theo, computacao_quantica).

% OTAVIO: Perfil "Regular" (Concluiu do 1 ao 4)
cursou(otavio, fundamentos_sistemas_ciberfisicos).
cursou(otavio, resolucao_problemas_logica_matematica).
cursou(otavio, filosofia).
cursou(otavio, exp_criativa_navegando).
cursou(otavio, raciocinio_algoritmico).
cursou(otavio, resolucao_problemas_discreta).
cursou(otavio, arquitetura_banco_dados).
cursou(otavio, programacao_imperativa).
cursou(otavio, programacao_web).
cursou(otavio, conectividade_sistemas_ciberfisicos).
cursou(otavio, etica).
cursou(otavio, modelagem_fenomenos_fisicos).
cursou(otavio, exp_criativa_criando_solucoes).
cursou(otavio, programacao_orientada_objetos).
cursou(otavio, seguranca_informacao).
cursou(otavio, performance_sistemas_ciberfisicos).
cursou(otavio, clinica_tic).
cursou(otavio, teologia_sociedade).
cursou(otavio, resolucao_problemas_estruturados).
cursou(otavio, programacao_logica_funcional).
cursou(otavio, big_data).
cursou(otavio, sistemas_operacionais).
cursou(otavio, redes_convergentes).
cursou(otavio, modelagem_sistemas_computacionais).