# Decisões de Modelagem e Limitações

Este documento registra as principais escolhas de implementação e soluções adotadas
durante o desenvolvimento das Camadas 1 e 2 do sistema Curriculum Advisor em Prolog,
atendendo aos requisitos de qualidade e robustez do PjBL 1.

---

## Camada 1: Base de Fatos

### 1. Representação de Átomos

Optou-se por utilizar átomos puros em minúsculo com underscores (ex:
`arquitetura_banco_dados`) para representar o nome das disciplinas, em vez de texto
entre aspas duplas (`"Arquitetura de Banco de Dados"`).

**Justificativa:** Em Prolog clássico (e por padrão em muitos sistemas, incluindo o
tratamento de `"..."` como lista de códigos de caractere em modo ISO), texto entre
aspas duplas não é a mesma coisa que um átomo — é uma lista de números representando
os códigos de caractere de cada letra. Duas strings com o mesmo conteúdo textual até
"parecem iguais" quando impressas, mas por baixo dos panos podem se comportar de
forma diferente na unificação dependendo da flag `double_quotes` ativa. Usar átomos
evita essa ambiguidade completamente: `arquitetura_banco_dados` é sempre o mesmo
termo atômico, comparável e unificável de forma direta e previsível em qualquer
consulta. Isso também simplifica a escrita de consultas
(`disciplina(arquitetura_banco_dados, T, C, S)` unifica direto, sem precisar lidar
com igualdade de listas de caracteres).

### 2. Modelagem Relacional de Pré-requisitos

Os pré-requisitos foram modelados de forma atômica com a estrutura
`prerequisito(Disciplina, Prerequisito)`, com um fato para cada dependência — nunca
uma lista de pré-requisitos dentro de um único fato (ex.: não fizemos algo como
`prerequisito(engenharia_software, [programacao_orientada_objetos, etica])`).

**Justificativa:** Essa é uma das armadilhas explicitamente citadas no enunciado
(Seção 5, Camada 1). Colocar múltiplos pré-requisitos dentro de uma lista parece mais
"compacto", mas quebra o motor de inferência relacional do Prolog: para descobrir se
uma disciplina X está dentro da lista de pré-requisitos de Y, seria preciso escrever
lógica extra de percorrer lista (`member/2`) em vez de simplesmente unificar
`prerequisito(Y, X)`. Isso complica desnecessariamente qualquer predicado que precise
iterar pré-requisitos (como o `forall/2` da Camada 2, ou o fecho transitivo recursivo
da Camada 3 — cada chamada recursiva vira uma busca simples por fatos, sem precisar
desmembrar listas). "Muitos fatos pequenos" é o idioma natural de Prolog: cada fato é
uma linha de uma tabela relacional, e o motor de resolução já sabe percorrer essas
linhas via backtracking sem ajuda extra.

Além disso, criamos deliberadamente **quatro cadeias de pré-requisitos com
profundidade ≥ 3** (o mínimo exigido é uma), para dar mais robustez aos testes de
fecho transitivo da Camada 3 e cobrir áreas diferentes do currículo:

| # | Cadeia | Profundidade | Área |
|---|--------|--------------|------|
| 1 | `engenharia_software → programacao_orientada_objetos → programacao_imperativa → raciocinio_algoritmico` | 3 | Programação |
| 2 | `inteligencia_artificial → aprendizagem_maquina → big_data → arquitetura_banco_dados → raciocinio_algoritmico` | 4 | Dados / IA |
| 3 | `programacao_distribuida → redes_convergentes → conectividade_sistemas_ciberfisicos → fundamentos_sistemas_ciberfisicos` | 3 | Redes / Sistemas Ciberfísicos |
| 4 | `complexidade_algoritmos → resolucao_problemas_estruturados → resolucao_problemas_discreta → resolucao_problemas_logica_matematica` | 3 | Resolução de Problemas |

As cadeias 3 e 4 foram criadas ligando disciplinas que já existiam na grade mas ainda
não tinham pré-requisito próprio (`programacao_distribuida` e
`resolucao_problemas_estruturados`), escolhendo dependências que fazem sentido
curricular (só faz sentido estudar sistemas distribuídos depois de entender redes
convergentes; só faz sentido resolver problemas "estruturados" depois de entender
resolução de problemas "discreta"). Evitamos criar disciplinas artificiais só para
inflar a profundidade.

### 3. Perfis dos Alunos

Os fatos de histórico (`cursou/2`) foram populados com uma grade real, divididos em
quatro perfis de teste estratégicos para forçar o sistema a avaliar todos os cenários
possíveis de elegibilidade:

* **david:** Ritmo normal, concluiu os semestres 1–3 por completo, meio do curso.
* **theo:** Adiantado, concluiu os semestres 1–5 e já cursou eletivas.
* **joao:** Histórico de trancamento, apenas 4 disciplinas avulsas do semestre 1.
* **otavio:** Regular em progressão, concluiu os semestres 1–4 por completo.

**Justificativa:** com apenas dois perfis (um adiantado e um atrasado) já seria
possível testar os predicados da Camada 2, mas quatro perfis cobrindo pontos
diferentes da grade (recém-começando, no meio, quase formado, com trancamento) dão
uma superfície de teste muito mais rica para a Camada 3 — em especial para gerar
trilhas válidas a partir de pontos de partida bem diferentes.

---

## Camada 2: Regras de Elegibilidade

### 1. Tratamento da Negação por Falha (`\+`)

No predicado `pode_cursar/2`, a verificação de que o aluno ainda não fez a disciplina
foi posicionada *depois* da instanciação da variável `Disciplina` via
`disciplina(Disciplina, _, _, _)`.

**Justificativa:** esta é a armadilha central da Camada 2 (Seção 5). Aplicar
`\+ cursou(Aluno, Disciplina)` com `Disciplina` ainda **livre** (não instanciada) não
gera um erro, mas produz um resultado quase sempre inútil: o interpretador tentaria
provar `cursou(Aluno, Disciplina)` com `Disciplina` livre, o que normalmente **tem
sucesso** na primeira disciplina que o aluno cursou (o Prolog só precisa achar *uma*
solução para provar o existencial). A negação por falha então falha (porque a coisa
que ela negava foi provada), e o predicado inteiro falha — mesmo que o aluno não
tenha cursado a disciplina X que realmente se queria testar. Ou seja: com a ordem
errada, `pode_cursar` teria vazado silenciosamente "qualquer aluno com pelo menos uma
disciplina cursada nunca pode cursar nada", o que é absurdo e o tipo de bug que passa
despercebido porque não gera erro nenhum — só resultado errado. Instanciar
`Disciplina` antes, via `disciplina/4`, resolve isso: o Prolog já percorre uma
disciplina concreta por vez (via backtracking do `disciplina/4`), e só então a
negação testa exatamente "o aluno cursou *esta* disciplina específica?" — que é a
pergunta certa.

### 2. Escolha entre `setof/3` e `findall/3`

Esta escolha foi deliberada dependendo do objetivo do predicado:

* **`setof/3`** — usado em `disciplinas_liberadas/2` e `disciplinas_pendentes/2`.
  *Justificativa:* estas consultas exigem um conjunto limpo (sem disciplinas
  duplicadas) e ordenado. Foi implementado o tratamento de exceção estrutural com OU
  lógico (`-> true ; Lista = []`) para evitar que o `setof` falhe (`false`) em casos
  em que o aluno não tem nenhuma disciplina liberada/pendente — sem esse tratamento,
  a consulta simplesmente falharia em vez de responder "lista vazia", o que seria uma
  resposta técnica confusa para quem está consultando.

* **`findall/3`** — usado em `creditos_cursados/2`.
  *Justificativa:* aqui o objetivo é uma extração bruta de valores inteiros (créditos)
  para somar. Como disciplinas diferentes podem ter a mesma quantidade de créditos
  (ex.: várias com 4 créditos), remover duplicatas — que é exatamente o que `setof`
  faria — corromperia o cálculo total no `sum_list/2`, descartando créditos reais do
  somatório. `findall/3` nunca remove duplicatas nem falha em lista vazia (devolve
  `[]`), o que é exatamente o comportamento desejado aqui.

### 3. Correção aplicada: variável livre "escondida" dentro do `setof/3`

Durante os testes de validação (carregando o projeto real no SWI-Prolog), foi
detectado um bug em `disciplinas_pendentes/2`: o predicado devolvia uma lista
incompleta — no caso do aluno `david`, por exemplo, devolvia só
`[teologia_sociedade]` em vez das 18 disciplinas obrigatórias realmente pendentes.

**Causa raiz:** a consulta original era

```prolog
setof(D, (disciplina(D, obrigatoria, _, _), \+ cursou(Aluno, D)), Lista)
```

Os dois `_` dentro de `disciplina(D, obrigatoria, _, _)` (Créditos e Semestre) são
variáveis livres que aparecem **diretamente no objetivo passado ao `setof`** — e não
"escondidas" dentro da chamada de outro predicado (como acontece em
`disciplinas_liberadas/2`, cujo objetivo é apenas `pode_cursar(Aluno, D)`, e as
variáveis internas de `pode_cursar/2` ficam encapsuladas dentro da definição desse
predicado, invisíveis para o `setof` de fora). Toda variável livre que não aparece no
Template (o primeiro argumento do `setof`) é tratada como uma **variável de
agrupamento ("witness")**: o `setof` gera uma lista separada para *cada combinação*
de valores dessas variáveis, em vez de uma lista única. No nosso caso, isso produzia
seis listas — uma por combinação de (Créditos, Semestre) — e a consulta `-> true`
ficava satisfeita com a **primeira** delas, descartando as outras cinco.

**Correção:** quantificar essas variáveis existencialmente com `^`, sinalizando ao
`setof` que elas devem variar livremente *dentro* de cada solução, e não servir de
critério de agrupamento:

```prolog
setof(D, Creditos^Semestre^(disciplina(D, obrigatoria, Creditos, Semestre), \+ cursou(Aluno, D)), Lista)
```

Após a correção, `disciplinas_pendentes(david, L)` devolve as 18 disciplinas
corretas, batendo com o resultado de um `findall/3` de controle usado para validar a
correção.

**Limitação conhecida:** esse é um padrão de erro sutil e fácil de reintroduzir —
qualquer nova consulta que use `setof/3`/`bagof/3` com um objetivo escrito
*diretamente* (não encapsulado em outro predicado) precisa ser revisada manualmente
quanto a variáveis livres não intencionais antes da entrega final.

### 4. Aplicação do `forall/2`

Implementado em `prerequisitos_ok/2` para iterar as restrições de pré-requisito.

**Justificativa:** a ordem estrita `forall(Condicao, Acao)` foi respeitada para
**checar uma propriedade** (todos os pré-requisitos foram cumpridos) em vez de tentar
coletar dados com ele — usar `forall/2` para coleta é outra armadilha citada no
enunciado, já que `forall/2` não devolve uma lista de resultados, apenas
verdadeiro/falso. `prerequisitos_ok/2` garante que a disciplina só seja marcada como
liberada se o aluno possuir **todos** os requisitos diretos mapeados para ela na base
de fatos — se o `forall` encontrar um único pré-requisito não cursado, o predicado
inteiro falha, que é exatamente a semântica de "E lógico para todos os casos".

### 5. Correção técnica de carregamento: `ensure_loaded/1` em vez de `consult/1`

`elegibilidade.pl` originalmente carregava a base de fatos com
`:- consult('curriculum.pl').`. Isso funciona sozinho, mas na integração final do
projeto (quando `main.pl` e `trilhas.pl` também precisarem da base de fatos),
múltiplos arquivos chamando `consult/1` sobre o mesmo arquivo fariam o SWI-Prolog
recarregar `curriculum.pl` várias vezes, gerando *warnings* de redefinição de
predicado. Como o enunciado (Seção 6) exige que o arquivo principal carregue **sem
nenhum warning**, trocamos para `:- ensure_loaded('curriculum.pl').`, que carrega o
arquivo apenas uma vez, não importa quantos outros arquivos dependam dele.

### 6. Correção técnica de encoding: diretiva `:- encoding(utf8).`

Os comentários em português usam acentuação (ex.: "pré-requisito", "é", "não"). Sem
declarar explicitamente o encoding do arquivo-fonte, o SWI-Prolog pode interpretar
esses bytes UTF-8 incorretamente e emitir warnings de "Illegal multibyte Sequence" ao
carregar — o que também violaria a exigência de carregamento limpo da Seção 6.
Adicionamos `:- encoding(utf8).` como a primeira diretiva de `curriculum.pl` e de
`elegibilidade.pl`, garantindo leitura correta dos comentários acentuados.

---

## Limitações Conhecidas (Camadas 1 e 2)

* A base de fatos representa uma grade curricular real, mas simplificada: não modela
  equivalência entre disciplinas de currículos antigos/novos nem carga horária
  prática vs. teórica separadamente.
* `prerequisitos_ok/2` só verifica pré-requisitos **diretos**. Um aluno que, por
  algum motivo hipotético, tivesse o pré-requisito direto cursado mas não os
  pré-requisitos *dele*, ainda passaria nesta camada — o fecho transitivo completo é
  responsabilidade da Camada 3 (`prerequisito_transitivo/2`), ainda não implementada
  neste estágio da entrega.
* Como registrado no item 3 acima, o uso de `setof/3`/`bagof/3` com metas escritas
  diretamente (sem encapsular em predicado) exige atenção redobrada a variáveis
  livres não quantificadas — é um risco recorrente para qualquer extensão futura do
  código.

---

## Aula rápida: os conceitos de Prolog usados neste projeto

Esta seção não é exigida pelo enunciado — é uma referência de estudo para quem for
defender o trabalho na arguição oral.

### 1. Fatos, regras e unificação

Em Prolog, tudo é feito de **termos**. Um fato como

```prolog
disciplina(programacao_web, obrigatoria, 4, 2).
```

é uma afirmação incondicional: "isso é verdade, ponto final". Uma regra como

```prolog
prerequisitos_ok(Aluno, Disciplina) :-
    forall(prerequisito(Disciplina, PreReq), cursou(Aluno, PreReq)).
```

é uma afirmação condicional: "a cabeça (`prerequisitos_ok(...)`) é verdadeira **se**
o corpo (depois do `:-`) for verdadeiro". Quando você faz uma pergunta ao Prolog (uma
*query*), o motor tenta **unificar** essa pergunta com a cabeça de fatos e regras da
base — ou seja, encontrar valores para as variáveis que tornam os dois termos
idênticos. `disciplina(programacao_web, T, C, S)` unifica com o fato acima fazendo
`T = obrigatoria`, `C = 4`, `S = 2`. É esse mecanismo de "casar padrões" que
substitui os `if/else` explícitos de linguagens imperativas: você não diz *como*
achar a resposta, só descreve *o que* é verdade, e o motor de inferência busca.

### 2. Backtracking

Quando uma consulta tem mais de uma forma de ser satisfeita, o Prolog tenta uma, e se
depois algo falhar, **volta atrás** (backtrack) e tenta a próxima alternativa
automaticamente. É exatamente isso que faz `disciplina(Disciplina, _, _, _)`
funcionar como um "for each" implícito dentro de `pode_cursar/2`: o Prolog testa a
primeira disciplina da base, roda o resto do corpo da regra; se falhar em algum ponto
(por exemplo, o aluno já cursou aquela disciplina), ele **desfaz** as instanciações
daquela tentativa e volta para tentar a próxima disciplina — sem que seja preciso
escrever nenhum laço explícito. É esse mesmo mecanismo que, na Camada 3, vai gerar
diferentes trilhas de disciplinas por tentativa e erro controlado.

### 3. Fechamento de mundo (Closed-World Assumption) e negação por falha (`\+`)

Prolog não tem um conceito de "verdadeiramente falso" — ele assume que **tudo que não
consegue provar é falso** (essa é a "hipótese de mundo fechado"). `\+ Objetivo`
("negação por falha") não significa "prove que Objetivo é falso"; significa **"tente
provar Objetivo; se a tentativa falhar (não encontrar nenhuma solução), então
`\+ Objetivo` tem sucesso"**. A pegadinha: se `Objetivo` contém uma variável livre,
"tentar provar" pode ter sucesso com a primeira coisa que casar — mesmo que não seja
o caso específico que se queria testar (foi exatamente o bug do item 1 desta seção,
aplicado ao `pode_cursar/2` do jeito errado). A regra prática: **sempre instancie
(dê um valor concreto a) as variáveis relevantes antes de negar.**

### 4. `findall/3`, `bagof/3` e `setof/3` — as três formas de "coletar tudo"

Os três predicados resolvem o mesmo problema geral ("me dê todas as soluções de um
objetivo, numa lista"), mas com diferenças importantes:

| Predicado | Duplicatas? | Ordenado? | Se não houver solução... | Variáveis livres extras |
|---|---|---|---|---|
| `findall/3` | mantém | não | devolve `[]` (nunca falha) | ignora — sempre junta tudo numa lista só |
| `bagof/3` | mantém | não | **falha** | agrupa por combinação, a menos que você quantifique com `^` |
| `setof/3` | remove | sim (ordem padrão) | **falha** | agrupa por combinação, a menos que você quantifique com `^` |

O ponto mais traiçoeiro (e que realmente pegou este projeto, ver item 3 da seção
anterior) é a última coluna: `bagof/3` e `setof/3` tratam **qualquer variável que
apareça no objetivo mas não no Template como um critério de agrupamento**, mesmo que
seja um `_` anônimo. Se você quer que essas variáveis simplesmente "existam e
variem" sem formar grupos separados, precisa avisar explicitamente com
`Var^Objetivo`. É por isso que a versão corrigida de `disciplinas_pendentes/2`
ficou:

```prolog
setof(D, Creditos^Semestre^(disciplina(D, obrigatoria, Creditos, Semestre), \+ cursou(Aluno, D)), Lista)
```

Uma forma de evitar esse risco por completo (usada em `disciplinas_liberadas/2`) é
**encapsular o objetivo dentro de outro predicado** (`pode_cursar/2`) — as variáveis
internas de um predicado chamado não "vazam" para quem faz o `setof` de fora, então
não existe risco de agrupamento acidental.

### 5. `forall/2` não é para coletar, é para verificar

`forall(Condicao, Acao)` só devolve verdadeiro ou falso — nunca uma lista.
Internamente ele é equivalente a `\+ (Condicao, \+ Acao)`: "não existe um caso em
que a Condição vale e a Ação falha", ou seja, "para todo caso em que a Condição é
satisfeita, a Ação também precisa ser satisfeita". É a ferramenta certa quando a
pergunta é "isso vale para tudo?" (como em `prerequisitos_ok/2`), e a ferramenta
errada quando a pergunta é "me dê a lista de tudo que satisfaz X" — para isso,
`findall/setof/bagof`.

### 6. Por que isso importa para a Camada 3

Todos esses conceitos se combinam na próxima camada: o fecho transitivo
(`prerequisito_transitivo/2`) vai depender de recursão bem fundada (caso base + caso
recursivo, para não entrar em loop infinito); a geração de trilhas
(`trilha_valida/3`) vai depender de backtracking deliberado para testar diferentes
combinações de disciplinas por semestre; e enumerar múltiplas trilhas vai usar
`findall/3` sobre um objetivo que gera soluções via backtracking — o mesmo
mecanismo de fundo, em um problema mais complexo.