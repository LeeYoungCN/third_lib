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

#ifndef __MOCKCPP_INTERFACE_INFO_H_
#define __MOCKCPP_INTERFACE_INFO_H_

#if defined(__GNUC__)
#include <typeinfo>
#endif

#include <mockcpp/mockcpp.h>

MOCKCPP_NS_START

#if defined(__GNUC__) && !defined(__clang__)

//////////////////////////////////////////////////////
unsigned int
getNumberOfBaseClasses(const std::type_info& info);

//////////////////////////////////////////////////////
template <typename Interface>
unsigned int getNumberOfVtbls()
{
   return getNumberOfBaseClasses(typeid(Interface));
}

#else

template <typename Interface>
unsigned int getNumberOfVtbls()
{
   // temparly comment out it to support mocking some complecated classes on VS
   // return sizeof(Interface)/sizeof(void*);
   return 2; 
}

#endif

MOCKCPP_NS_END

#endif

