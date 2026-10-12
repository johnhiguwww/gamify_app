    1
    Edite o codigoSalve as alteracoes no codigo Flutter normalmente (models, telas, o que for).
    2
    Gere o build novoNo terminal, dentro da pasta do projeto (S:\projeto\gamify\gamify), rode: flutter build web 
    Isso gera de novo a pasta build/web com a versao atualizada.
    3
    Publique de novoAinda na mesma pasta, rode: firebase deploy Ele vai subir o conteudo atualizado de build/web pra mesma URL de sempre (https://gamify-app-ce12f.web.app).
    4
    Atualize a pagina com cache limpoAbra a URL no navegador e de um Ctrl+Shift+R (ou Cmd+Shift+R no Mac) pra forcar o navegador a buscar a versao nova, ja que ele costuma guardar cache dos arquivos web.

