//
//  NativeCodeTest.hpp
//  AzureAppConfigurationObjC
//
//  Created by Travis Prescott on 9/10/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

#ifndef NativeCodeTest_hpp
#define NativeCodeTest_hpp

#include <stdio.h>

class NativeInt {
public:
    NativeInt(int);
    int get();
private:
    int m_Int;
};

#endif /* NativeCodeTest_hpp */
