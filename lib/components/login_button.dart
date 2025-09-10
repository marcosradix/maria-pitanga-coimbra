import 'package:flutter/material.dart';

class LoadingButton extends StatefulWidget {
  final String text;
  final Future<void> Function() onPressed;

  const LoadingButton({super.key, required this.text, required this.onPressed});

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool _isLoading = false;

  void _handlePress() async {
    setState(() => _isLoading = true);
    await widget.onPressed();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handlePress,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        padding: EdgeInsets.symmetric(vertical: 16),
        textStyle: TextStyle(fontSize: 18),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              widget.text,
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
    );
  }
}
