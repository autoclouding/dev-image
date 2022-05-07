FROM ubuntu:21.04

# Install SSH and SUPERVISOR
RUN apt update
RUN apt install -y openssh-server
RUN apt install -y supervisor
RUN apt install -y apt-transport-https
RUN apt install -y software-properties-common

# Copy the sshd_config file to the /etc/ssh/ directory
COPY ./ssh/sshd_config /etc/ssh/
COPY ./root/* /root
COPY ./supervisor/supervisor.conf /etc/supervisor/conf.d/

RUN ssh-keygen -A
RUN mkdir -p /run/sshd
RUN echo 'root:$6$gOK7eS2IyWBgwhOM$mRCAkN.fpAMwhDghBmZpS6WIfUdP98v.qFyi5oGldfKCZiFb2bormeUeO.1.ABGwVOr2eMM9n1e.QpmVs4Rm7.' | chpasswd -e

# Install Tools
RUN apt install -y git vim jq curl wget git zsh sudo golang build-essential gcc g++ make autojump fasd fonts-powerline


# Install oh-my-zsh
RUN sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/themes/powerlevel10k
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Install Azure CLI
# RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install dotnet dsk + runtime - This is installed from the binaries, as of today .NET 6.0 is not supported by the deb repositories for Ubuntu 22.04
# RUN wget -O /tmp/dotnet.deb https://packages.microsoft.com/config/ubuntu/21.04/packages-microsoft-prod.deb
# RUN dpkg -i /tmp/dotnet.deb
# RUN apt update
# RUN apt install -y dotnet-sdk-6.0
RUN wget -O /tmp/dotnet.tar.gz "https://download.visualstudio.microsoft.com/download/pr/c505a449-9ecf-4352-8629-56216f521616/bd6807340faae05b61de340c8bf161e8/dotnet-sdk-6.0.201-linux-x64.tar.gz"
RUN (mkdir dotnet && cd dotnet && tar xzvf /tmp/dotnet.tar.gz && cd .. && mv dotnet /usr/share && rm -rf /tmp/dotnet.tar.gz)
RUN echo "export PATH=\"$PATH:/usr/share/dotnet\"" >> /root/.bashrc

# Install NodeJS 17
RUN ( curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash - ) ; echo "Successx"
RUN apt update
RUN apt remove -y nodejs-legacy
RUN apt install -y nodejs rsyslog

# Install terraform
RUN ( curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - )
RUN yes | apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
RUN apt update
RUN apt install -y terraform

ENV PATH="/root/go/bin:${PATH}"
RUN go install github.com/swaggo/swag/cmd/swag@v1.7.9


# RUN wget https://github.com/swaggo/swag/releases/download/v1.7.9/swag_1.7.9_Linux_x86_64.tar.gz -O /tmp/swag.tar.gz
# RUN ( cd /tmp ; tar xzvf swag.tar.gz ; mv swag /bin )

# Open port 2222 for SSH access
EXPOSE 80 443 2222 3000 3333 8001 8080 4200
WORKDIR /opt/app
# Copy local angular/nest code to the container
# COPY . .
# Build production app
# RUN npm install && npm run build:prod:api && npm prune --production

# CMD ["npm", "run", "start:prod:api"]
# CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisor.conf"]
