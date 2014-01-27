# Copyright 2012-2013 Hewlett-Packard Development Company, L.P.
# All Rights Reserved.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
# This should have some discryption as to what it does really
import os

from paste import deploy

from keystone import config
from keystone.common import logging

LOG = logging.getLogger(__name__)
CONF = config.CONF
config_files = ['/etc/keystone/keystone.conf']
CONF(project='keystone', default_config_files=config_files)

conf = CONF.config_file[0]
name = os.path.basename(__file__)

if CONF.debug:
    CONF.log_opt_values(logging.getLogger(CONF.prog), logging.DEBUG)

options = deploy.appconfig('config:%s' % CONF.config_file[0])

application = deploy.loadapp('config:%s' % conf, name=name)
