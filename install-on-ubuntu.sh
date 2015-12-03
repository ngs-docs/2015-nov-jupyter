#! /bin/bash

# ubuntu-wily-15.10-amd64-server-20151116.1 (ami-26d5af4c)

set -x
set -e

sudo apt-get -y update
sudo apt-get -y install r-base python3-matplotlib libzmq3-dev python3.5-dev texlive-latex-extra texlive-latex-recommended python3-virtualenv

cd ~/
python3 -m virtualenv -p python3.5 env --system-site-packages
. ~/env/bin/activate

pip3 install -U jupyter jupyter_client ipython pandas

jupyter notebook --generate-config

cat >>/home/ubuntu/.jupyter/jupyter_notebook_config.py <<EOF
c = get_config()
c.NotebookApp.ip = '*'
c.NotebookApp.open_browser = False
c.NotebookApp.password = u'sha1:5d813e5d59a7:b4e430cf6dbd1aad04838c6e9cf684f4d76e245c'
c.NotebookApp.port = 8000

EOF

# install bash kernel, following: https://github.com/takluyver/bash_kernel
pip install bash_kernel
python -m bash_kernel.install


# install R kernel, following: http://irkernel.github.io/installation/
cat >>install-irkernel.sh <<EOF
install.packages(c('rzmq','repr','IRkernel','IRdisplay'),
                 repos = c('http://irkernel.github.io/',
                           'http://cran.us.r-project.org'))
EOF

sudo R --no-save < install-irkernel.sh
echo 'IRkernel::installspec()' | R --no-save

cd
git clone https://github.com/damianavila/RISE.git
cd RISE
python setup.py install

cd
cat >run-notebook.sh <<EOF
#! /bin/bash
. ~ubuntu/env/bin/activate
jupyter notebook
EOF

chmod +x run-notebook.sh
screen -d -m ./run-notebook.sh
