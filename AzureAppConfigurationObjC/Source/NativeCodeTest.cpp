//
//  NativeCodeTest.cpp
//  AzureAppConfigurationObjC
//
//  Created by Travis Prescott on 9/10/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

#include "NativeCodeTest.hpp"

NativeInt::NativeInt(int _i) : m_Int(_i) {}
int NativeInt::get() { return m_Int; }

