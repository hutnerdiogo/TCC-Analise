# TCC - Análise Empírica do Ajuste de Preço após Dividendos: Proposição do β\_div

**Autor**: Diogo Hutner
**Contato**: [diogohutner@gmail.com](mailto:diogohutner@gmail.com)
**Base de Dados**: [Download do banco de dados (.sqlite)](https://1drv.ms/u/s!Aki2-4bzD8pFp-VFWPL0d0mT3y92fw?e=m6rbge)

---

## 📘 Resumo

Este repositório contém todo o código utilizado na construção do Trabalho de Conclusão de Curso (TCC) cujo objetivo é investigar empiricamente o comportamento dos preços de ações no mercado norte-americano após eventos de distribuição de dividendos. A partir disso, propõe-se uma nova métrica batizada de **β\_div**, que mede de forma agregada e individual a sensibilidade do preço ao montante distribuído em dividendos.

A proposta do β\_div se baseia na constatação empírica de que, embora o desconto pelo dividendo seja previsto teoricamente, seu valor real apresenta variação considerável entre empresas, setores e momentos de mercado. Através da análise de mais de **76 mil eventos ex-dividend**, buscamos medir, quantificar e entender esse comportamento.

---

## 🧠 Fundamentação e Objetivo

A literatura financeira sugere que os preços de ações devem ajustar-se à distribuição de dividendos no exato montante pago, implicando um retorno ajustado próximo de zero. No entanto, evidências mostram que o retorno no dia ex-dividend tende a ser **negativo**, mas não necessariamente igual ao valor distribuído. Essa distorção é atribuída a fatores como:

* Clientela de dividendos (Elton & Gruber, 1970)
* Fricções de mercado
* Preferência fiscal
* Expectativas e ruídos

O **β\_div** surge como uma tentativa de sistematizar esse ajuste através de um modelo econométrico simples, porém eficaz, para entender o quanto, de fato, o mercado desconta os dividendos no preço de abertura do pregão seguinte.

---

## 📁 Estrutura do Projeto

O notebook está estruturado em seções temáticas, com o seguinte fluxo lógico:

1. **Importação**
   Importação de pacotes e bibliotecas utilizadas ao longo do projeto.

2. **Modelagem de Dados**
   Definição de classes, dataclasses e estruturas auxiliares para manuseio de ativos e eventos.

3. **Funções e Utilitários**
   Funções reutilizáveis para filtragem, coleta, agregação e padronização dos dados.

4. **Obtenção e Filtragem de Ativos**

   * Coleta de dados via Yahoo Finance (`yfinance`)
   * Filtragem por liquidez e frequência de pagamento
   * Construção de uma tabela `tickers` com atributos-chave dos ativos

5. **Formalização dos Eventos**

   * Construção do dataset com os eventos *ex-dividend*
   * Cálculo de retornos antes e depois da data de corte
   * Normalização dos dividendos pagos

6. **Cálculo do β\_div**

   * Aplicação de regressão linear simples:
     $R_{am} = \alpha + \beta_{div} \cdot D + \varepsilon$
     Onde:

     * $R_{am}$: retorno aftermarket
     * $D$: valor do dividendo
   * Geração de β\_div agregado e individual por ativo

7. **Análises Complementares**

   * Estudo de heterogeneidade dos betas por setor
   * Análise por quintis de distribuição
   * Testes de robustez e significância estatística

8. **Visualizações**

   * Gráficos de dispersão e distribuição dos coeficientes
   * Análises comparativas entre grupos de ativos

---

## 🛠️ Tecnologias e Bibliotecas Utilizadas

* `pandas`, `numpy` – manipulação de dados
* `matplotlib`, `seaborn` – visualização
* `sqlite3`, `pickle` – persistência de dados
* `statsmodels` – regressão linear e testes estatísticos
* `yfinance` – coleta de dados de mercado
* `aiohttp`, `asyncio` – aceleração de requisições paralelas
* `tqdm` – progresso em loops

---

## 💡 Como Rodar

1. **Clone o repositório e instale as dependências**
   Recomenda-se o uso de um ambiente virtual.

   ```bash
   git clone https://github.com/seuusuario/tcc-beta-div.git
   cd tcc-beta-div
   pip install -r requirements.txt  # ou pip install -e .
   ```

2. **Coloque o banco de dados na pasta data**
   Faça o download da base `.sqlite` [clicando aqui](https://1drv.ms/u/s!Aki2-4bzD8pFp-VFWPL0d0mT3y92fw?e=m6rbge) e salve com o nome `dividends_data.sqlite`.

3. **Execute o notebook**
   Abra o `tcc.ipynb` em um ambiente como Jupyter Notebook, JupyterLab ou VSCode e execute célula por célula.

---

## 📊 Exemplos de Saída

* Gráficos de dispersão entre retorno aftermarket e dividendos pagos
* Histograma do β\_div individual por ativo
* Tabela de betas médios por setor
* Regressões com robustez a heterocedasticidade

---

## 📌 Conclusão

Este projeto demonstrou que o ajuste de preços após dividendos é real, sistemático e altamente variável. O **β\_div** permite mensurar de forma objetiva essa sensibilidade, abrindo espaço para estudos adicionais sobre preferências dos investidores e mecanismos de formação de preços.
