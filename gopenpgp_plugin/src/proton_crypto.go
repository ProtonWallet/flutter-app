package main

/*
#include <stdlib.h>
#include <string.h>
struct BinaryResult {
    int length;
    char* data;
};
*/
import "C"
import (
	"fmt"
	"strings"
	"unsafe"

	armor_helper "github.com/ProtonMail/gopenpgp/v2/armor"
	"github.com/ProtonMail/gopenpgp/v2/crypto"
	"github.com/ProtonMail/gopenpgp/v2/helper"
	"github.com/pkg/errors"
)

type KeyArray []*crypto.Key

//export encryptWithKeyRing
func encryptWithKeyRing(userPublicKeysSepInComma *C.char, message *C.char) *C.char {
	keyString := C.GoString(userPublicKeysSepInComma)
	arr := strings.Split(keyString, ",")
	keys := make(KeyArray, len(arr))
	for i, keyStr := range arr {
		key, err := crypto.NewKeyFromArmored(keyStr)
		if err != nil {
			fmt.Println("Error parsing key:", err)
			return nil
		}
		keys[i] = key
	}
	keyRing, err := keys.ToKeyRing()
	if err != nil {
		fmt.Println("ToKeyRing error:", err)
		return nil
	}

	pgpMessage, err := keyRing.Encrypt(crypto.NewPlainMessageFromString(C.GoString(message)), nil)
	if err != nil {
		fmt.Println("Encryption error:", err)
		return nil
	}

	armor, err := pgpMessage.GetArmored()
	if err != nil {
		fmt.Println("GetArmored error:", err)
		return nil
	}
	return C.CString(armor)
}

//export getArmoredPublicKey
func getArmoredPublicKey(userPrivateKey *C.char) *C.char {
	privateKeyObj, _ := crypto.NewKeyFromArmored(C.GoString(userPrivateKey))
	armoredPublicKey, err := privateKeyObj.GetArmoredPublicKey()
    if err != nil {
        fmt.Printf("Failed to armor public key: %v", err)
    }
	return C.CString(armoredPublicKey)
}

//export encrypt
func encrypt(userPrivateKey *C.char, message *C.char) *C.char {
	key, _ := crypto.NewKeyFromArmored(C.GoString(userPrivateKey))
	userPublicKey, _ := key.GetArmoredPublicKey()
	armor, _ := helper.EncryptMessageArmored(userPublicKey, C.GoString(message))
	return C.CString(armor)
}

//export getSignatureWithContext
func getSignatureWithContext(userPrivateKey *C.char, passphrase *C.char, message *C.char, context *C.char) *C.char {
	plainMessage := crypto.NewPlainMessageFromString(C.GoString(message))
	passphraseBytes := []byte(C.GoString(passphrase))
	privateKeyObj, _ := crypto.NewKeyFromArmored(C.GoString(userPrivateKey))
	unlockedKeyObj, _ := privateKeyObj.Unlock(passphraseBytes)
	signingKeyRing, _ := crypto.NewKeyRing(unlockedKeyObj)

	pgpSignature, err := signingKeyRing.SignDetachedWithContext(plainMessage, crypto.NewSigningContext(C.GoString(context), true))
	if err != nil {
		fmt.Printf("Error in getSignature: %v\n", err)
		return nil
	}
	pgpSignatureArmor, _ := pgpSignature.GetArmored()
	return C.CString(pgpSignatureArmor)
}

//export verifySignatureWithContext
func verifySignatureWithContext(userPublicKey *C.char, message *C.char, signature *C.char, context *C.char) C.int {
	plainMessage := crypto.NewPlainMessageFromString(C.GoString(message))
	signatures := splitPGPSignatures(C.GoString(signature))
	publicKeyObj, _ := crypto.NewKeyFromArmored(C.GoString(userPublicKey))
	signingKeyRing, _ := crypto.NewKeyRing(publicKeyObj)
	for _, pgpSignatureString := range signatures {
		pgpSignature, _ := crypto.NewPGPSignatureFromArmored(pgpSignatureString)
		err := signingKeyRing.VerifyDetachedWithContext(plainMessage, pgpSignature, crypto.GetUnixTime(), crypto.NewVerificationContext(C.GoString(context), true, 0))
		if err == nil {
			return C.int(1)
		}
	}

	return C.int(0)
}

//export getBinarySignatureWithContext
func getBinarySignatureWithContext(userPrivateKey *C.char, passphrase *C.char, binaryMessage *C.char, length C.int, context *C.char) *C.char {
	data := C.GoBytes(unsafe.Pointer(binaryMessage), length)
	plainMessage := crypto.NewPlainMessage(data)
	passphraseBytes := []byte(C.GoString(passphrase))
	privateKeyObj, _ := crypto.NewKeyFromArmored(C.GoString(userPrivateKey))
	unlockedKeyObj, _ := privateKeyObj.Unlock(passphraseBytes)
	signingKeyRing, _ := crypto.NewKeyRing(unlockedKeyObj)

	pgpSignature, err := signingKeyRing.SignDetachedWithContext(plainMessage, crypto.NewSigningContext(C.GoString(context), true))
	if err != nil {
		fmt.Printf("Error in getSignature: %v\n", err)
		return nil
	}
	pgpSignatureArmor, _ := pgpSignature.GetArmored()
	return C.CString(pgpSignatureArmor)
}

//export verifyBinarySignatureWithContext
func verifyBinarySignatureWithContext(userPublicKey *C.char, binaryMessage *C.char, length C.int, signature *C.char, context *C.char) C.int {
	data := C.GoBytes(unsafe.Pointer(binaryMessage), length)
	plainMessage := crypto.NewPlainMessage(data)
	signatures := splitPGPSignatures(C.GoString(signature))
	publicKeyObj, _ := crypto.NewKeyFromArmored(C.GoString(userPublicKey))
	signingKeyRing, _ := crypto.NewKeyRing(publicKeyObj)
	for _, pgpSignatureString := range signatures {
		pgpSignature, _ := crypto.NewPGPSignatureFromArmored(pgpSignatureString)
		err := signingKeyRing.VerifyDetachedWithContext(plainMessage, pgpSignature, crypto.GetUnixTime(), crypto.NewVerificationContext(C.GoString(context), true, 0))
		if err == nil {
			return C.int(1)
		}
	}

	return C.int(0)
}

//export getSignature
func getSignature(userPrivateKey *C.char, passphrase *C.char, message *C.char) *C.char {
	plainMessage := crypto.NewPlainMessageFromString(C.GoString(message))
	passphraseBytes := []byte(C.GoString(passphrase))
	privateKeyObj, _ := crypto.NewKeyFromArmored(C.GoString(userPrivateKey))
	unlockedKeyObj, _ := privateKeyObj.Unlock(passphraseBytes)
	signingKeyRing, _ := crypto.NewKeyRing(unlockedKeyObj)

	pgpSignature, err := signingKeyRing.SignDetached(plainMessage)
	if err != nil {
		fmt.Printf("Error in getSignature: %v\n", err)
		return nil
	}
	pgpSignatureArmor, _ := pgpSignature.GetArmored()
	return C.CString(pgpSignatureArmor)
}

//export verifySignature
func verifySignature(userPublicKey *C.char, message *C.char, signature *C.char) C.int {
	plainMessage := crypto.NewPlainMessageFromString(C.GoString(message))
	signatures := splitPGPSignatures(C.GoString(signature))
	publicKeyObj, _ := crypto.NewKeyFromArmored(C.GoString(userPublicKey))
	signingKeyRing, _ := crypto.NewKeyRing(publicKeyObj)
	for _, pgpSignatureString := range signatures {
		pgpSignature, _ := crypto.NewPGPSignatureFromArmored(pgpSignatureString)
		err := signingKeyRing.VerifyDetached(plainMessage, pgpSignature, crypto.GetUnixTime())
		if err == nil {
			return C.int(1)
		}
	}

	return C.int(0)
}

//export decrypt
func decrypt(userPrivateKey *C.char, passphrase *C.char, armor *C.char) *C.char {
	passphraseBytes := []byte(C.GoString(passphrase))
	decryptedMessage, _ := helper.DecryptMessageArmored(C.GoString(userPrivateKey), passphraseBytes, C.GoString(armor))
	return C.CString(decryptedMessage)
}

//export encryptBinary
func encryptBinary(userPrivateKey *C.char, binaryMessage *C.char, length C.int) C.struct_BinaryResult {
	data := C.GoBytes(unsafe.Pointer(binaryMessage), length)
	key, _ := crypto.NewKeyFromArmored(C.GoString(userPrivateKey))
	userPublicKey, _ := key.GetArmoredPublicKey()
	armor, _ := helper.EncryptBinaryMessageArmored(userPublicKey, data)
	encryptedBinary, _ := armor_helper.Unarmor(armor)
	resultBytes := GoBytes2CBytes(encryptedBinary)
	resultBytesLength := C.int(len(encryptedBinary))
	return C.struct_BinaryResult{length: resultBytesLength, data: resultBytes}
}

//export verifyCleartextMessageArmored
func verifyCleartextMessageArmored(userPublicKey *C.char, armoredSignature *C.char) (*C.char, C.int) {
	clearText, err := helper.VerifyCleartextMessageArmored(C.GoString(userPublicKey), C.GoString(armoredSignature), crypto.GetUnixTime())
	cStr := C.CString(clearText)
	if err == nil {
		return cStr, C.int(1)
	}
	return cStr, C.int(0)
}

//export encryptBinaryArmor
func encryptBinaryArmor(userPrivateKey *C.char, binaryMessage *C.char, length C.int) *C.char {
	data := C.GoBytes(unsafe.Pointer(binaryMessage), length)
	key, _ := crypto.NewKeyFromArmored(C.GoString(userPrivateKey))
	userPublicKey, _ := key.GetArmoredPublicKey()
	armor, _ := helper.EncryptBinaryMessageArmored(userPublicKey, data)
	return C.CString(armor)
}

//export decryptBinary
func decryptBinary(userPrivateKey *C.char, passphrase *C.char, encryptedBinary *C.char, length C.int) C.struct_BinaryResult {
	data := C.GoBytes(unsafe.Pointer(encryptedBinary), length)
	passphraseBytes := []byte(C.GoString(passphrase))
	ciphertext := crypto.NewPGPMessage(data)

	message, err := decryptMessage(C.GoString(userPrivateKey), passphraseBytes, ciphertext)
	if err != nil {
		fmt.Printf("Error in decryptMessage: %v\n", err)
		return C.struct_BinaryResult{length: C.int(0), data: GoBytes2CBytes(make([]byte, 0))}
	}

	resultBytes := GoBytes2CBytes(message.GetBinary())
	resultBytesLength := C.int(len(message.GetBinary()))
	return C.struct_BinaryResult{length: resultBytesLength, data: resultBytes}
}

//export enforce_binding
func enforce_binding() {}

// function from: https://github.com/ProtonMail/gopenpgp/blob/main/helper/helper.go#L392
func decryptMessage(privateKey string, passphrase []byte, ciphertext *crypto.PGPMessage) (*crypto.PlainMessage, error) {
	privateKeyObj, err := crypto.NewKeyFromArmored(privateKey)
	if err != nil {
		return nil, errors.Wrap(err, "gopenpgp: unable to parse the private key")
	}

	privateKeyUnlocked, err := privateKeyObj.Unlock(passphrase)
	if err != nil {
		return nil, errors.Wrap(err, "gopenpgp: unable to unlock key")
	}

	defer privateKeyUnlocked.ClearPrivateParams()

	privateKeyRing, err := crypto.NewKeyRing(privateKeyUnlocked)
	if err != nil {
		return nil, errors.Wrap(err, "gopenpgp: unable to create the private key ring")
	}

	message, err := privateKeyRing.Decrypt(ciphertext, nil, 0)
	if err != nil {
		return nil, errors.Wrap(err, "gopenpgp: unable to decrypt message")
	}

	return message, nil
}

func GoBytes2CBytes(bytes []byte) *C.char {
	str := string(bytes)
	cStr := C.CString(str)
	return cStr
}

func main() {}

func (keyArray KeyArray) ToKeyRing() (*crypto.KeyRing, error) {
	kr, _ := crypto.NewKeyRing(nil) // create empty KeyRing
	for _, key := range keyArray {
		if err := kr.AddKey(key); err != nil {
			return nil, err
		}
	}
	return kr, nil
}

func splitPGPSignatures(multiSig string) []string {
	beginMarker := "-----BEGIN PGP SIGNATURE-----"
	endMarker := "-----END PGP SIGNATURE-----"

	var signatures []string
	parts := strings.Split(multiSig, beginMarker)

	for _, part := range parts {
		part = strings.TrimSpace(part)
		if part == "" {
			continue
		}

		signature := beginMarker + "\n" + part
		if strings.Contains(signature, endMarker) {
			signatures = append(signatures, signature)
		}
	}

	return signatures
}
