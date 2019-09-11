//
//  NativeTest.cpp
//  AzureAppConfiguration
//
//  Created by Travis Prescott on 9/10/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

#include "NativeTest.hpp"

NativeTest::NativeTest(int _i) : m_Int(_i) {}

int NativeTest::getVal() {
    return m_Int;
}

extern "C" int getTestFromCPP(int i) {
    return NativeTest(i).getVal();
}
