package objectstorage

import "context"

// ObjectStorage 对象存储接口
type ObjectStorage interface {
	GetCredential(ctx context.Context, objectName string) (*Credential, error)
	GetObjectUrl(ctx context.Context, objectName string) (string, error)
	PutObject(ctx context.Context, fileName string, objectName string) error
}
