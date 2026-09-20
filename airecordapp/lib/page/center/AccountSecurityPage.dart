import 'package:airecordapp/constant/ErrConstants.dart';
import 'package:airecordapp/logic/ProfileLogic.dart';
import 'package:airecordapp/page/login/EmailLoginPage.dart';
import 'package:flutter/material.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';

class AccountSecurityPage extends StatefulWidget {
  @override
  State<AccountSecurityPage> createState() => _AccountSecurityPageState();
}

class _AccountSecurityPageState extends State<AccountSecurityPage> {
  final ProfileLogic _logic = ProfileLogic();
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: Stack(
          children: [
            AppBar(
              automaticallyImplyLeading: true,
              backgroundColor: Colors.white,
              centerTitle: true,
              title: Text(
                S.of(context).AccountSecurityPage_k1,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'PingFang SC-Semibold',
                    color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[100]),
        child: ListView(
          children: [
            const SizedBox(height: 8.0),
            _buildDeleteAccountSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAccountSection() {
    return Container(
      padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0, right: 16.0),
      margin: EdgeInsets.only(bottom: 16.0, left: 8.0, right: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        onTap: _isDeleting ? null : () => _confirmDeleteAccount(),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(Icons.delete_forever, color: Colors.red, size: 22),
                  SizedBox(width: 8),
                  Text(
                    S.of(context).AccountSecurityPage_k2,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'PingFang SC-Semibold',
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              _isDeleting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.navigate_next, color: Colors.black, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: Colors.white.withOpacity(0.5),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          backgroundColor: Colors.white,
          elevation: 10,
          alignment: Alignment.center,
          title: Text(
            S.of(context).AccountSecurityPage_k3,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          content: Text(
            S.of(context).AccountSecurityPage_k4,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(dialogContext).pop(false);
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey, width: 1.0),
                          right: BorderSide(color: Colors.grey, width: 0.5),
                        ),
                      ),
                      child: Text(
                        S.of(context).AccountSecurityPage_k5,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(dialogContext).pop(true);
                      _deleteAccount();
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey, width: 1.0),
                          left: BorderSide(color: Colors.grey, width: 0.5),
                        ),
                      ),
                      child: Text(
                        S.of(context).AccountSecurityPage_k6,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      final resp = await _logic.deleteAccount();
      if (resp.code == ErrConstants.SUCCESS_CODE) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => EmailLoginPage()),
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _isDeleting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).AccountSecurityPage_k7),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).AccountSecurityPage_k7),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
