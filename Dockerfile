FROM neurodebian:nd90
ENV DEBIAN_FRONTEND=noninteractive

# Let's install some build-depends for wrapt
RUN sed -e 's,deb ,deb-src ,g' /etc/apt/sources.list > /etc/apt/sources.list.d/debsrc.list
RUN apt-get update -qqq

# speed things up
RUN apt-get install -y eatmydata
# just to get all dependencies but then also python-dbg for better debugging
RUN eatmydata apt-get install -y datalad python-dbg
RUN apt-get build-dep -y python-wrapt

# additional helpers and uptodate git-annex (for some reason didn't get pulled in)
RUN apt-get install -y python-pip git-annex-standalone

# Purge installed versions so we could install straight from  git
RUN dpkg --purge datalad python-datalad 

# Later -- prune also those
# python-wrapt python-vcr

# the "master" of segfaulting
RUN git clone http://github.com/mih/datalad /tmp/datalad
WORKDIR /tmp/datalad
RUN git checkout 210a3d7; 
RUN pip install -e '.[full]'

# Run the tests
RUN python -m nose -s -v  datalad
