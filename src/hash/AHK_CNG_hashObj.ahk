﻿class hash { ; to extend/be embedded in main obj
    
    md2(string,file=0){
        return this.hashThis(string,"MD2",file)
    }
    
    md4(string,file=0){
        return this.hashThis(string,"MD4",file)
    }
    
    md5(string,file=0){
        return this.hashThis(string,"MD5",file)
    }
    
    sha1(string,file=0){
        return this.hashThis(string,"SHA1",file)
    }
    
    sha256(string,file=0){
        return this.hashThis(string,"SHA256",file)
    }
    
    sha384(string,file=0){
        return this.hashThis(string,"SHA384",file)
    }
    
    sha512(string,file=0){
        return this.hashThis(string,"SHA512",file)
    }
    
    hashThis(string,BCRYPT_ALGORITHM,file=0){
    
        static BCRYPT_OBJECT_LENGTH := "ObjectLength"
        static BCRYPT_HASH_LENGTH   := "HashDigestLength"
        hash:=""
        
        if !(hBCRYPT := DllCall("LoadLibrary", "str", "bcrypt.dll", "ptr"))
            throw Exception("Failed to load bcrypt.dll", -1)
        
        if (NT_STATUS := DllCall("bcrypt\BCryptOpenAlgorithmProvider", "ptr*", hAlgo, "ptr", &BCRYPT_ALGORITHM, "ptr", 0, "uint", 0) != 0)
            throw Exception("BCryptOpenAlgorithmProvider: " NT_STATUS, -1)
        
        if (NT_STATUS := DllCall("bcrypt\BCryptGetProperty", "ptr", hAlgo, "ptr", &BCRYPT_HASH_LENGTH, "uint*", cbHash, "uint", 4, "uint*", cbResult, "uint", 0) != 0)
            throw Exception("BCryptGetProperty: " NT_STATUS, -1)

        if(a_OSVersion!="Win_10"){
            if (NT_STATUS := DllCall("bcrypt\BCryptGetProperty", "ptr", hAlgo, "ptr", &BCRYPT_OBJECT_LENGTH, "uint*", cbHashObject, "uint", 4, "uint*", cbResult, "uint", 0) != 0)
                throw Exception("BCryptGetProperty: " NT_STATUS, -1)
            
            VarSetCapacity(pbHashObject, cbHashObject, 0)
            if (NT_STATUS := DllCall("bcrypt\BCryptCreateHash", "ptr", hAlgo, "ptr*", hHash, "ptr", &pbHashObject, "uint", cbHashObject, "ptr", 0, "uint", 0, "uint", 0) != 0)
                throw Exception("BCryptCreateHash: " NT_STATUS, -1)
        
            if(!file){
                VarSetCapacity(pbInput, cbInput := StrPut(string, "UTF-8"), 0) && StrPut(string, &pbInput, "UTF-8")
                if (NT_STATUS := DllCall("bcrypt\BCryptHashData", "ptr", hHash, "ptr", &pbInput, "uint", cbInput - 1, "uint", 0) != 0)
                    throw Exception("BCryptHashData: " NT_STATUS, -1)
            }else{
                if !(f := FileOpen(string, "r", "UTF-8"))
                    throw Exception("Failed to open file: " string, -1)
                while !(f.AtEOF) && (dataread := f.RawRead(data, 262144))
                    if (NT_STATUS := DllCall("bcrypt\BCryptHashData", "ptr", hHash, "ptr", &data, "uint", dataread, "uint", 0) != 0)
                        throw Exception("BCryptHashData: " NT_STATUS, -1)
                f.Close()
            }
            VarSetCapacity(pbHash, cbHash, 0)
            if (NT_STATUS := DllCall("bcrypt\BCryptFinishHash", "ptr", hHash, "ptr", &pbHash, "uint", cbHash, "uint", 0) != 0)
                throw Exception("BCryptFinishHash: " NT_STATUS, -1)
        }else{
            if(!file){
                VarSetCapacity(pbHash, cbHash, 0)
                VarSetCapacity(pbInput, cbInput := StrPut(string, "UTF-8"), 0) && StrPut(string, &pbInput, "UTF-8")
                if (NT_STATUS := DllCall("bcrypt\BCryptHash", "ptr", hAlgo, "ptr", 0, "uint", 0, "ptr", &pbInput, "uint", cbInput - 1, "ptr", &pbHash, "uint", cbHash) != 0)
                    throw Exception("BCryptHash: " NT_STATUS, -1)
            }else{
                VarSetCapacity(pbHash, cbHash, 0)
                if !(f := FileOpen(filename, "r", "UTF-8"))
                    throw Exception("Failed to open file: " filename, -1)
                while !(f.AtEOF) && (dataread := f.RawRead(data, 262144))
                    if (NT_STATUS := DllCall("bcrypt\BCryptHash", "ptr", hAlgo, "ptr", 0, "uint", 0, "ptr", &data, "uint", dataread, "ptr", &pbHash, "uint", cbHash) != 0)
                        throw Exception("BCryptHash: " NT_STATUS, -1)
                f.Close()
            }
        }
        
        loop % cbHash
            hash .= Format("{:02x}", NumGet(pbHash, A_Index - 1, "UChar"))

        if(a_OSVersion!="Win_10")
            DllCall("bcrypt\BCryptDestroyHash", "ptr", hHash)
        DllCall("bcrypt\BCryptCloseAlgorithmProvider", "ptr", hAlgo, "uint", 0)
        DllCall("FreeLibrary", "ptr", hBCRYPT)
        
        return hash
    }
    

    class hmac {
        
        md2(string,hmac,file=0){
            return this.hmacThis(string,hmac,"MD2",file)
        }

        md4(string,hmac,file=0){
            return this.hmacThis(string,hmac,"MD4",file)
        }

        md5(string,hmac,file=0){
            return this.hmacThis(string,hmac,"MD5",file)
        }

        sha1(string,hmac,file=0){
            return this.hmacThis(string,hmac,"SHA1",file)
        }

        sha256(string,hmac,file=0){
            return this.hmacThis(string,hmac,"SHA256",file)
        }

        sha384(string,hmac,file=0){
            return this.hmacThis(string,hmac,"SHA384",file)
        }

        sha512(string,hmac,file=0){
            return this.hmacThis(string,hmac,"SHA512",file)
        }
        
        hmacThis(string,hmac,BCRYPT_ALGORITHM,file=0){
            
            static BCRYPT_ALG_HANDLE_HMAC_FLAG := 0x00000008
            static BCRYPT_OBJECT_LENGTH        := "ObjectLength"
            static BCRYPT_HASH_LENGTH          := "HashDigestLength"
            hash:=""
            
            if !(hBCRYPT := DllCall("LoadLibrary", "str", "bcrypt.dll", "ptr"))
                throw Exception("Failed to load bcrypt.dll", -1)
            
            if (NT_STATUS := DllCall("bcrypt\BCryptOpenAlgorithmProvider", "ptr*", hAlgo, "ptr", &BCRYPT_ALGORITHM, "ptr", 0, "uint", BCRYPT_ALG_HANDLE_HMAC_FLAG) != 0)
                throw Exception("BCryptOpenAlgorithmProvider: " NT_STATUS, -1)

            if (NT_STATUS := DllCall("bcrypt\BCryptGetProperty", "ptr", hAlgo, "ptr", &BCRYPT_HASH_LENGTH, "uint*", cbHash, "uint", 4, "uint*", cbResult, "uint", 0) != 0)
                throw Exception("BCryptGetProperty: " NT_STATUS, -1)
            
            if(a_OSVersion!="Win_10"){
                if (NT_STATUS := DllCall("bcrypt\BCryptGetProperty", "ptr", hAlgo, "ptr", &BCRYPT_OBJECT_LENGTH, "uint*", cbHashObject, "uint", 4, "uint*", cbResult, "uint", 0) != 0)
                    throw Exception("BCryptGetProperty: " NT_STATUS, -1)
                
                VarSetCapacity(pbHashObject, cbHashObject, 0)
                VarSetCapacity(pbSecret, cbSecret := StrPut(hmac, "UTF-8"), 0) && StrPut(hmac, &pbSecret, "UTF-8")
                VarSetCapacity(pbHash, cbHash, 0)
                if (NT_STATUS := DllCall("bcrypt\BCryptCreateHash", "ptr", hAlgo, "ptr*", hHash, "ptr", &pbHashObject, "uint", cbHashObject, "ptr", &pbSecret, "uint", cbSecret - 1, "uint", 0) != 0)
                    throw Exception("BCryptCreateHash: " NT_STATUS, -1)
                
                if(!file){
                    VarSetCapacity(pbInput, cbInput := StrPut(string, "UTF-8"), 0) && StrPut(string, &pbInput, "UTF-8")
                    if (NT_STATUS := DllCall("bcrypt\BCryptHashData", "ptr", hHash, "ptr", &pbInput, "uint", cbInput - 1, "uint", 0) != 0)
                        throw Exception("BCryptHashData: " NT_STATUS, -1)
                }else{
                    if !(f := FileOpen(string, "r", "UTF-8"))
                        throw Exception("Failed to open file: " string, -1)
                    while !(f.AtEOF) && (dataread := f.RawRead(data, 262144))
                        if (NT_STATUS := DllCall("bcrypt\BCryptHashData", "ptr", hHash, "ptr", &data, "uint", dataread, "uint", 0) != 0)
                            throw Exception("BCryptHashData: " NT_STATUS, -1)
                    f.Close()
                }
                if (NT_STATUS := DllCall("bcrypt\BCryptFinishHash", "ptr", hHash, "ptr", &pbHash, "uint", cbHash, "uint", 0) != 0)
                    throw Exception("BCryptFinishHash: " NT_STATUS, -1)
            }else{
                VarSetCapacity(pbInput,  cbInput  := StrPut(string, "UTF-8"), 0) && StrPut(string, &pbInput,  "UTF-8")
                VarSetCapacity(pbSecret, cbSecret := StrPut(hmac, "UTF-8"), 0)   && StrPut(hmac,   &pbSecret, "UTF-8")
                VarSetCapacity(pbHash, cbHash, 0)

                if (NT_STATUS := DllCall("bcrypt\BCryptHash", "ptr", hAlgo, "ptr", &pbSecret, "uint", cbSecret, "ptr", &pbInput, "uint", cbInput - 1, "ptr", &pbHash, "uint", cbHash) != 0)
                    throw Exception("BCryptHash: " NT_STATUS, -1)
            }
            
            loop % cbHash
                hash .= Format("{:02x}", NumGet(pbHash, A_Index - 1, "UChar"))
            
            if(a_OSVersion!="Win_10")
                DllCall("bcrypt\BCryptDestroyHash", "ptr", hHash)
            DllCall("bcrypt\BCryptCloseAlgorithmProvider", "ptr", hAlgo, "uint", 0)
            DllCall("FreeLibrary", "ptr", hBCRYPT)
            
            return hash
        }
    }
    
    class pbkdf2 {
        md2(password,salt,iterations=4096,keysize=16){
            return this.pbkdf2This(password,salt,"MD2",iterations,keysize)
        }
        
        md4(password,salt,iterations=4096,keysize=16){
            return this.pbkdf2This(password,salt,"MD4",iterations,keysize)
        }
        
        md5(password,salt,iterations=4096,keysize=16){
            return this.pbkdf2This(password,salt,"MD5",iterations,keysize)
        }
        
        sha1(password,salt,iterations=4096,keysize=16){
            return this.pbkdf2This(password,salt,"SHA1",iterations,keysize)
        }
        
        sha256(password,salt,iterations=4096,keysize=16){
            return this.pbkdf2This(password,salt,"SHA256",iterations,keysize)
        }
        
        sha384(password,salt,iterations=4096,keysize=16){
            return this.pbkdf2This(password,salt,"SHA384",iterations,keysize)
        }
        
        sha512(password,salt,iterations=4096,keysize=16){
            return this.pbkdf2This(password,salt,"SHA512",iterations,keysize)
        }
        
        pbkdf2This(password,salt,BCRYPT_ALGORITHM,iterations=4096,keysize=16){
            static BCRYPT_ALG_HANDLE_HMAC_FLAG := 0x00000008

            if !(hBCRYPT := DllCall("LoadLibrary", "str", "bcrypt.dll", "ptr"))
                throw Exception("Failed to load bcrypt.dll", -1)

            if (NT_STATUS := DllCall("bcrypt\BCryptOpenAlgorithmProvider", "ptr*", hAlgo, "ptr", &BCRYPT_ALGORITHM, "ptr", 0, "uint", BCRYPT_ALG_HANDLE_HMAC_FLAG) != 0)
                throw Exception("BCryptOpenAlgorithmProvider: " NT_STATUS, -1)

            VarSetCapacity(pbPass, cbPass := StrPut(password, "UTF-8"), 0) && StrPut(password, &pbPass, "UTF-8")
            VarSetCapacity(pbSalt, cbSalt := StrPut(salt, "UTF-8"), 0) && StrPut(salt, &pbSalt, "UTF-8")
            VarSetCapacity(pbDKey, keysize, 0)
            if (NT_STATUS := DllCall("bcrypt\BCryptDeriveKeyPBKDF2", "ptr", hAlgo, "ptr", &pbPass, "uint", cbPass - 1, "ptr", &pbSalt, "uint", cbSalt - 1, "int64", iterations, "ptr", &pbDKey, "uint", keysize, "uint", 0) != 0)
                throw Exception("BCryptDeriveKeyPBKDF2: " NT_STATUS, -1)

            loop % keysize
                pbkdf2 .= Format("{:02x}", NumGet(pbDKey, A_Index - 1, "UChar"))

            DllCall("bcrypt\BCryptCloseAlgorithmProvider", "ptr", hAlgo, "uint", 0)
            DllCall("FreeLibrary", "ptr", hBCRYPT)

            return pbkdf2
        }
    }
}
