Simulação Monte Carlo para Fluxo Unificado
==========================================

Rode os exemplos. Exemplo:

ruby marx_example.rb > marx.csv

Faça uma cópia da planilha abaixo:

https://docs.google.com/spreadsheets/d/1x5pPEdVY0PjAf16RasAebGlERFP3Sp_1dtvsT2wuRBQ/edit?usp=sharing

Importe o marx.csv para a primeira aba da planilha. Importe substituindo os dados a partir da célula A1. Use o separador ";". Veja imagem:

!(screenshot.png)

O modelo permite plugar diferentes "Queue Disciplines" para simular a probabilidade de término de diversos projetos dentro de um mesmo fluxo (aka Fluxo Unificado).

Como é uma project_spec?
========================

['A', [*12..17], [today - 7, today - 5, today - 6]]

'A' - Id único do projeto
[*12..17] - Range de quantidade de demandas do Backlog (estime o scope creep e dark matter)
[today - 7, today - 5, today - 6] - Demandas do projeto que já estão no WIP e suas datas de início

