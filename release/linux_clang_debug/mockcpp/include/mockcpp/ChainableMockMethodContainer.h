/***
   mockcpp is a C/C++ mock framework.
   Copyright [2008] [Darwin Yuan <darwin.yuan@gmail.com>]

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
***/
#ifndef __MOCKCPP_CHAINABLE_MOCK_METHOD_CONTAINER_H
#define __MOCKCPP_CHAINABLE_MOCK_METHOD_CONTAINER_H

#include <mockcpp/mockcpp.h>

#include <string>

MOCKCPP_NS_START

struct ChainableMockMethodContainerImpl;
struct ChainableMockMethodKey;
struct ChainableMockMethodCore;
struct InvocationMocker;

///////////////////////////////////////////////////////////////
struct ChainableMockMethodContainer
{
    ChainableMockMethodContainer();
    ~ChainableMockMethodContainer();

    ChainableMockMethodCore* getMethod(ChainableMockMethodKey* key) const;
    void addMethod(ChainableMockMethodKey* key, ChainableMockMethodCore* method);

    InvocationMocker* findInvocationMocker(const std::string& id) const;

    void reset();
    void verify();

private:
    ChainableMockMethodContainerImpl* This;
};

MOCKCPP_NS_END

#endif

