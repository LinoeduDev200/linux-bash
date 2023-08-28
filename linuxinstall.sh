#!/bin/bash
# Copyright 2023 Criado por EDUARDO LINO.

show_main_menu() {
    choice=$(zenity --list --title="Menu Principal" --column="Opção" "Instalar Programas" "Atualizar Sistema" "Remover Programas Desnecessários" "Reparar Sistema" "Instalar Programas do arquivo txt" "Instalar/Remover Programas Flatpak" "Instalar/Remover Programas Snap" "Sair" --width="300" --height="350")

    case "$choice" in
        "Instalar Programas")
            install_individual_packages--text=" $nome" --width="100" height="50"
            ;;
        "Atualizar Sistema")
            update_system
            ;;
        "Remover Programas Desnecessários")
            remove_unnecessary_packages
            ;;
        "Reparar Sistema")
            repair_system
            ;;
        "Instalar Programas do arquivo txt")
            install_packages_from_txt
            ;;
        "Instalar/Remover Programas Flatpak")
            manage_flatpak
            ;;
        "Instalar/Remover Programas Snap")
            manage_snap
            ;;
        "Sair")
            exit
            ;;
        *)
            show_main_menu
            ;;
    esac
}

# Função para instalar pacotes individualmente
install_individual_packages() {
    packages=$(zenity --entry --title="Instalar Pacotes" --text="Digite os nomes dos pacotes a serem instalados (separados por espaço):")
    install_packages "$distribution" "$packages"
    show_message "Pacotes instalados com sucesso!"
}

# Função para instalar pacotes
install_packages() {
    case "$1" in
        "Arch")
             if ! pacman -Qs $packages > /dev/null; then
                sudo pacman -S --needed $packages
            else
                show_message "O programa $packages já está instalado."
            fi
            ;;
        "Fedora")
           if ! rpm -q $packages > /dev/null; then
                sudo dnf install $packages
            else
                show_message "O programa $packages já está instalado."
            fi
            ;;
        "Ubuntu")
           
                       
    for nome in ${packages[*]}; do
      if ! dpkg -l | grep -q $nome && ! snap list | grep -q $nome && ! flatpak list | grep -q $nome  ; then 
      # Só instala se não estiver instalado
        rhino-pkg install "$nome" 
     else
      show_message "O programa $nome já está instalado."
     fi

  done
                      
            ;;
        *)
            show_message "Distribuição não suportada."
            ;;
    esac
}

# Função para atualizar o sistema
update_system() {
    case "$distribution" in
        "Arch")
            sudo pacman -Syu
            ;;
        "Fedora")
            sudo dnf update
            ;;
        "Ubuntu")
            echo "Atualizandeo e Instalando App nescessários "
               sudo apt update && sudo apt upgrade
               sudo apt install -y git python3-pip python3-dev curl snapd make chrome-gnome-shell nala  dotnet-sdk-6.0 exa flatpak wget npm 
               sudo bash -c "$(curl -fsSL https://pacstall.dev/q/install || wget -q https://pacstall.dev/q/install -O -)"
               sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
               sudo apt install gnome-software-plugin-flatpak
               pacstall -I rhino-pkg-git
               rhino-pkg update
            ;;
        *)
            show_message "Distribuição não suportada."
            ;;
    esac
}

# Função para remover pacotes desnecessários
remove_unnecessary_packages() {
    case "$distribution" in
        "Arch")
            sudo pacman -Rns $(pacman -Qdtq)
            ;;
        "Fedora")
            sudo dnf autoremove
            ;;
        "Ubuntu")
            sudo apt-get autoremove
            ;;
        *)
            show_message "Distribuição não suportada."
            ;;
    esac
}

# Função para reparar o sistema
repair_system() {
    case "$distribution" in
        "Arch")
            sudo pacman -Syu --needed
            ;;
        "Fedora")
            sudo dnf distro-sync
            ;;
        "Ubuntu")
            sudo apt-get install -f
            ;;
        *)
            show_message "Distribuição não suportada."
            ;;
    esac
}

# Função para instalar pacotes a partir de um arquivo txt
install_packages_from_txt() {
    packages_file=$(zenity --file-selection --title="Selecione um arquivo .txt com a lista de pacotes a instalar")
    packages=$(cat "$packages_file")
    install_packages "$distribution" "$packages"
    show_message "Pacotes instalados com sucesso!"
}

# Função para instalar/remover pacotes Flatpak
manage_flatpak() {
    action=$(zenity --list --title="Gerenciar Pacotes Flatpak" --column="Ação" "Instalar" "Remover" "Cancelar")

    case "$action" in
        "Instalar")
            flatpak_packages=$(zenity --entry --title="Instalar Pacotes Flatpak" --text="Digite os nomes dos pacotes Flatpak a serem instalados (separados por espaço):")
            for package in $flatpak_packages; do
                flatpak install $package
            done
            show_message "Pacotes Flatpak instalados com sucesso!"
            ;;
        "Remover")
            flatpak_packages=$(flatpak list --app --columns=application | tail -n +2 | awk '{print $1}')
            package_to_remove=$(zenity --list --title="Remover Pacotes Flatpak" --column="Pacote" "${flatpak_packages[@]}")
            flatpak uninstall -y $package_to_remove
            show_message "Pacote Flatpak removido com sucesso!"
            ;;
        *)
            show_main_menu
            ;;
    esac
}

# Função para instalar/remover pacotes Snap
manage_snap() {
    action=$(zenity --list --title="Gerenciar Pacotes Snap" --column="Ação" "Instalar" "Remover" "Cancelar")

    case "$action" in
        "Instalar")
            snap_packages=$(zenity --entry --title="Instalar Pacotes Snap" --text="Digite os nomes dos pacotes Snap a serem instalados (separados por espaço):")
            for package in $snap_packages; do
                sudo snap install $package
            done
            show_message "Pacotes Snap instalados com sucesso!"
            ;;
        "Remover")
            snap_packages=$(sudo snap list | tail -n +2 | awk '{print $1}')
            package_to_remove=$(zenity --list --title="Remover Pacotes Snap" --column="Pacote" "${snap_packages[@]}")
            sudo snap remove $package_to_remove
            show_message "Pacote Snap removido com sucesso!"
            ;;
        *)
            show_main_menu
            ;;
    esac
}

# Função para exibir uma caixa de diálogo de mensagem
show_message() {
    zenity --info --text="$1" --width=300 
}

# Leitura da escolha da distribuição
distribution=$(zenity --list --title="Escolha a distribuição" --column="Distribuição" "Arch" "Fedora" "Ubuntu")

# Loop principal
while true; do
    show_main_menu
done
# Copyright 2023 Criado por EDUARDO LINO.
