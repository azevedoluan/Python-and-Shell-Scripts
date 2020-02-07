# Rotina de verificação de caixa de e-mail
Rotina que mistura código em Python, Shell Script e procedure em PL/SQL para genteciar relatórios de vendas.
O programa Python entra na caixa de e-mail e processa todos os e-mail não lidos. Depois faz uma chamado de um shell script passando por
parâmetro o assunto e o remetente da mensagem. O shell chama uma procedure no banco onde busca o relatório de vendas do vendedor e envia
a resposta para o e-mail que solicitou o relatório.
Ao final da execução, o programa python remove os e-mails processados com sucesso.
