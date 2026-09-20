package utils

import "testing"

func TestAesGCM_Encrypt(t *testing.T) {
	type fields struct {
		key []byte
	}
	type args struct {
		plaintext string
	}
	tests := []struct {
		name    string
		fields  fields
		args    args
		wantErr bool
	}{
		{
			name: "AesGCM Crypto",
			fields: fields{
				key: []byte(GenerateMD5Hash("airecord.smarto.top")),
			},
			args: args{
				plaintext: "hello",
			},
			wantErr: false,
		},
		{
			name: "AesGCM Crypto empty string",
			fields: fields{
				key: []byte(GenerateMD5Hash("airecord.smarto.top")),
			},
			args: args{
				plaintext: "",
			},
			wantErr: false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			a := &AesGCM{
				key: tt.fields.key,
			}
			t.Logf("input plain: %s", tt.args.plaintext)
			got, err := a.Encrypt(tt.args.plaintext)
			if (err != nil) != tt.wantErr {
				t.Errorf("Encrypt() error = %v, wantErr %v", err, tt.wantErr)
				return
			}

			t.Logf("Encrypt() cipher: %s", got)

			plain, err := a.Decrypt(got)
			if (err != nil) != tt.wantErr {
				t.Errorf("Decrypt() err = %v, wantErr %v", err, tt.wantErr)
				return
			}
			t.Logf("Encrypt() plain: %s", plain)

			if tt.args.plaintext != plain {
				t.Errorf("Encrypt() plain = %v, want %v", tt.args.plaintext, plain)
			}
		})
	}
}
