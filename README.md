# BuscaCEP
Descrição
O BuscaCEP é um projeto desenvolvido em Delphi 11.3 Alexandria que permite a consulta de dados de endereço a partir de um CEP informado pelo usuário. 
Utiliza a API da ViaCEP para obter essas informações e exibi-las em formato JSON.

Funcionalidades
- Consulta de Endereço por CEP: O usuário informa o CEP e clica no botão "Consultar CEP". A aplicação se comunica com a API ViaCEP, e, caso a consulta seja bem-sucedida, as informações do endereço são exibidas.
- Retorno de Dados em JSON: As informações obtidas da API são retornadas e exibidas em formato JSON.
- Implementação de Clean Code: O projeto segue princípios de Clean Code, com ênfase na legibilidade, simplicidade e modularidade do código.
- Uso de Classes: A implementação utiliza classes para organizar a lógica da consulta e tratamento dos dados retornados pela API.

Como Funciona
- Entrada do CEP: O usuário insere o CEP que deseja consultar.
- Consulta à API: Ao clicar no botão "Consultar CEP", a aplicação faz uma requisição à API da ViaCEP.
- Exibição dos Resultados: Se a consulta for bem-sucedida, os dados do endereço correspondente ao CEP informado são exibidos em formato JSON na tela.

Tecnologias Utilizadas
- Delphi 11.3 Alexandria: Ambiente de desenvolvimento.
- API ViaCEP: Serviço externo para consulta de CEPs.
- JSON: Formato de retorno dos dados da API.