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

#ifndef __MOCKCPP_CHAINABLE_MOCK_OBJECT_BASE_H
#define __MOCKCPP_CHAINABLE_MOCK_OBJECT_BASE_H

#include <mockcpp/mockcpp.h>

#include <mockcpp/InvocationMockerNamespace.h>
#include <mockcpp/ChainableMockMethodContainer.h>

#include <string>

MOCKCPP_NS_START

struct ChainableMockObjectBaseImpl;
struct InvocationMocker;


struct ChainableMockObjectBase 
      : public InvocationMockerNamespace
{
public:

    ~ChainableMockObjectBase();

    const std::string& getName(void) const;

    // InvocationMockerNamespace -- id("id");
    InvocationMocker* getInvocationMocker(const std::string& id) const;

    virtual void verify();

protected:

    ChainableMockMethodContainer* getMethodContainer() const;

protected:

    explicit ChainableMockObjectBase(const std::string& name);

    ChainableMockObjectBase(const ChainableMockObjectBase&);

private:

    ChainableMockObjectBase& operator=(const ChainableMockObjectBase&);

protected:

    bool shared;

private:

    ChainableMockObjectBaseImpl* This;
};

MOCKCPP_NS_END

#endif

