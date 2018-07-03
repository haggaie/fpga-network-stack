#!groovy

/*
 * Copyright (c) 2016-2018 Haggai Eran, Gabi Malka, Lior Zeno, Maroun Tork
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 *  * Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation and/or
 * other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS IS''
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

properties ([parameters([
    choice(name: 'VIVADO_HLS_VERSION',
           description: 'The version of Vivado HLS to use for the build',
           choices: ['2018.2'].join('\n')),
    choice(name: 'VIVADO_VERSION',
           description: 'The version of Vivado to use for XCI generation',
           choices: ['2016.2', '2018.2'].join('\n')),
    choice(name: 'PART',
           description: 'Device part number to build for',
           choices: ['xcku060-ffva1156-2-i', 'vcu709', 'vcu118'].join('\n')),
])])

def vivadoHlsEnv() {
    return ". /opt/Xilinx/Vivado/${params.VIVADO_HLS_VERSION}/settings64.sh ;"
}

def vivadoEnv() {
    return ". /opt/Xilinx/Vivado/${params.VIVADO_VERSION}/settings64.sh ;"
}

node {
    stage('Preparation') {
        // Fetch our code
        checkout scm
    }
    stage('Build') {
        dir('hls') {
            // Run HLS unit tests (C simulation)
            sh vivadoHlsEnv() + "./generate_hls.sh ${params.PART}"

            // cleanup
            sh "find -maxdepth 4 -name .autopilot -exec rm -r '{}' ';'"
        }
        // copy zip files and reports
        archiveArtifacts "iprepo/*/*.zip"
    }
    stage('XCI generation') {
        dir('projects') {
            sh vivadoEnv() + "vivado -mode batch -source create_xci.tcl -tclargs ${params.PART}"
            currentBuild.result = 'SUCCESS'

            archiveArtifacts "xci/*/*.xci"
        }
    }
}
