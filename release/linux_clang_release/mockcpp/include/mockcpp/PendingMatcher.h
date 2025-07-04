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

#ifndef __MOCKCPP_PENDING_MATCHER_H
#define __MOCKCPP_PENDING_MATCHER_H

#include <mockcpp/mockcpp.h>
#include <mockcpp/Matcher.h>

#include <string>

MOCKCPP_NS_START

struct Invocation;
struct OrderingMatcher;
struct InvocationMockerNamespace;
struct InvocationMocker;

struct PendingMatcher : public Matcher
{
   PendingMatcher(OrderingMatcher* orderingMatcher
                 , InvocationMockerNamespace* ns
                 , const std::string& identity
                 , InvocationMocker* ThisMocker);

	~PendingMatcher();

	bool matches(const Invocation& inv) const;

	void increaseInvoked(const Invocation& inv);

	std::string toString() const;

	void verify();

private:

	void setUpOrderingMatcher() const;

private:

   mutable OrderingMatcher* matcher;
	InvocationMockerNamespace* scope;
   std::string id;
   InvocationMocker* mocker;
};

MOCKCPP_NS_END

#endif

