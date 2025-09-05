import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:maria_pitanga/services/auth_service.dart';
import 'package:maria_pitanga/utils/base64_utils.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        "https://maria-pitanga-e5e82-default-rtdb.europe-west1.firebasedatabase.app",
  ).ref("auth_data");
  AuthService authService = AuthService();
  bool accepted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showPrivacyPolicy() {
    const contactEmail = "mariapitangacoimbra@gmail.com";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Política de Privacidade"),
        content: SingleChildScrollView(
          child: const Text('''
A presente Política de Privacidade explica como recolhemos, utilizamos e protegemos os seus dados pessoais, em conformidade com o Regulamento Geral sobre a Proteção de Dados (RGPD).

1. Responsável: Textura Frutifera UNIP. LDA
2. Dados recolhidos: Nome, Email, Telefone
3. Finalidade: Gestão de contactos, comunicações e serviços
4. Direitos: Acesso, retificação, apagamento, oposição, portabilidade
5. Contacto: $contactEmail

Ao prosseguir, está a consentir com a recolha e tratamento dos dados acima descritos.

A presente Política de Privacidade explica como recolhemos, utilizamos e protegemos os seus dados pessoais, em conformidade com o Regulamento Geral sobre a Proteção de Dados (RGPD) - Regulamento (UE) 2016/679.

1. Responsável pelo Tratamento dos Dados

A responsabilidade pelo tratamento dos seus dados pessoais é da Textura Frutifera UNIP. LDA, com sede em avinida joão das regras 139, coimbra, podendo ser contactada através do e-mail mariapitangacoimbra@gmail.com.

2. Dados Pessoais Recolhidos

No âmbito da utilização do nosso website/serviços, poderemos recolher os seguintes dados pessoais:

Nome

Endereço de e-mail

Número de telefone

3. Finalidade do Tratamento

Os dados recolhidos serão utilizados para as seguintes finalidades:

Responder a pedidos de contacto ou informações solicitadas;

Envio de comunicações relevantes relacionadas com os nossos serviços/produtos;

Gestão de relacionamento com clientes e potenciais clientes.

4. Fundamento Jurídico

O tratamento dos seus dados pessoais baseia-se no seu consentimento (art. 6.º, n.º 1, alínea a) do RGPD), podendo este ser retirado a qualquer momento, sem comprometer a licitude do tratamento efetuado anteriormente.

5. Conservação dos Dados

Os seus dados serão conservados apenas pelo período estritamente necessário para cumprir as finalidades para que foram recolhidos, ou até que o titular exerça o direito de eliminação dos mesmos.

6. Partilha de Dados

Os seus dados não serão vendidos, partilhados ou cedidos a terceiros, exceto quando tal seja obrigatório por lei ou necessário para cumprimento de obrigações legais.

7. Direitos do Titular dos Dados

Nos termos do RGPD, tem o direito de:

Aceder aos seus dados pessoais;

Solicitar a retificação de dados incorretos ou desatualizados;

Solicitar o apagamento dos seus dados;

Opor-se ao tratamento ou solicitar a limitação do mesmo;

Solicitar a portabilidade dos dados.

Para exercer os seus direitos, poderá contactar-nos através do e-mail: $contactEmail.

8. Segurança dos Dados

Adotamos medidas técnicas e organizativas adequadas para garantir a proteção dos seus dados contra perda, alteração, acesso não autorizado ou divulgação indevida.

9. Alterações a esta Política

Poderemos atualizar esta Política de Privacidade sempre que necessário, sendo as alterações publicadas nesta página.
            '''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Fechar"),
          ),
        ],
      ),
    );
  }

  void _acceptTerms() {
    setState(() {
      accepted = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text("Termos aceites!"),
      ),
    );
    // Aqui pode navegar para outra página ou guardar no storage que o utilizador aceitou
  }

  void _salvar() async {
    if (_formKey.currentState!.validate() && accepted) {
      // Form is valid, proceed further
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final phone = _phoneController.text.trim();

      await authService.register(email, password).then((data) {
        final user = data!.user;
        if (user != null && !user.emailVerified) {
          _dbRef
              .child(Base64Utils.encode(email))
              .set({"phone": phone, "privacyPolicy": accepted})
              .catchError((error) {
                Get.snackbar("Erro", "Erro ao salvar dados");
              });

          user.sendEmailVerification();

          ScaffoldMessenger.of(context)
              .showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.purple,
                  content: Text("Dados salvos com sucesso!"),
                ),
              )
              .closed
              .then((_) {
                _formKey.currentState?.reset();
                _phoneController.clear();
                _emailController.clear();
                _passwordController.clear();
              });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Registo",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              shrinkWrap: true,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "E-mail",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe o E-mail';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: "Senha",
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe a Senha';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: "Telemóvel",
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe o Telemóvel';
                    }
                    return null;
                  },
                ),
                const Text(
                  "Para continuar, é necessário aceitar a nossa Política de Privacidade.",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _showPrivacyPolicy,
                  child: const Text("Ler a Política de Privacidade"),
                ),

                const SizedBox(height: 5),

                ElevatedButton.icon(
                  onPressed: _acceptTerms,
                  icon: const Icon(Icons.check),
                  label: const Text("Li e Aceito os Termos"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: _salvar,
        child: const Icon(Icons.save, color: Colors.white),
      ),
    );
  }
}
