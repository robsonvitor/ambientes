### Ambiente de desenvolvimento com LAPP (Linux, Apache, PostgreSQL e PHP)

> As configurações aqui apresentadas, são úteis somente em ambiente de desenvolvimento.

1. Instale o __VirtualBox__ e o __VirtualBox Extension Pack__ no seu sistema operacional: [Download][2]

1. Instale o __Vagrant__ no seu sistema operacional: [Download][3]

1. Através da linha de comando, instale os plugins:

    ```bash
    vagrant plugin install vagrant-vbguest

    vagrant plugin install vagrant-triggers

    vagrant plugin install vagrant-hostsupdater
    ```

1. Edite as variáveis, de acordo com seu computador, no arquivo Vagrantfile

1. Na primeira execução, utilize o comando: `` vagrant up --provision``
    *Obs: Irá demorar um pouco, pois irá efetuar o download da imagem e instalação de pacotes necessários. Aguarde!*
1. Após o processo anterior, se não ocorreu nenhum erro, o ambiente estará disponível no endereço IP configurado na variável IP no arquivo Vagrantfile

1. Informações adicionais:
    * __Para usuários de Windows, recomendo o__ **[Gitbash][1]**
    * __PostgreSQL:__
        * Usuário: postgres
        * Senha: postgres
    * __Acessar a VM via SSH:__
        ``vagrant ssh``
    * __Hypervisor utilizado:__
        VirtualBox
    * __Destruir a box__
        ``vagrant destroy``


[1]: https://git-for-windows.github.io/
[2]: https://www.virtualbox.org/wiki/Downloads
[3]: https://www.vagrantup.com/downloads.html
