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

#ifndef __MOCKCPP_MISMATCH_RESULT_HANDLER_FACTORY_H
#define __MOCKCPP_MISMATCH_RESULT_HANDLER_FACTORY_H

#include <mockcpp/mockcpp.h>
#include <mockcpp/ResultHandlerFactory.h>

MOCKCPP_NS_START

///////////////////////////////////////////////////////////
struct MismatchResultHandlerFactory
   : public ResultHandlerFactory
{
    ResultHandler* create(
            bool isCastable
          , const std::type_info& expectedTypeInfo
          , const std::string& expectedTypeString
          , const SelfDescribe* selfDescriber);
};

///////////////////////////////////////////////////////////

MOCKCPP_NS_END

#endif

