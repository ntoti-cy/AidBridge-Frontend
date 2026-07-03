import 'package:aid_bridge/Configs/colors.dart';
import 'package:aid_bridge/Controllers/auth/auth_state.dart';
import 'package:aid_bridge/Controllers/crud/crud_cubit.dart';
import 'package:aid_bridge/Dio/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class CompleteProfile extends StatefulWidget {
  const CompleteProfile({super.key});

  @override
  State<CompleteProfile> createState() =>
      _CompleteProfileState();
}

class _CompleteProfileState
    extends State<CompleteProfile> {
  //==========================================================
  // FORM
  //==========================================================

  final _formKey = GlobalKey<FormState>();

  final membersController =
      TextEditingController();

  final dependentsController =
      TextEditingController();

  final incomeController =
      TextEditingController();

  //==========================================================
  // STATE
  //==========================================================

  bool disabilityPresent = false;

  bool loadingCenters = true;

  bool showOfflineBanner = false;

  int? selectedCenterId;

  List<Map<String, dynamic>> centers = [];

  //==========================================================
  // LIFECYCLE
  //==========================================================

  @override
  void initState() {
    super.initState();

    _loadCenters();
  }

  @override
  void dispose() {
    membersController.dispose();
    dependentsController.dispose();
    incomeController.dispose();

    super.dispose();
  }

  //==========================================================
  // LOAD CENTRES
  //==========================================================

  Future<void> _loadCenters() async {
    try {
      final response =
          await DioClient.dio.get(
        "/api/crud/get-centers",
      );

      centers =
          List<Map<String, dynamic>>.from(
        response.data,
      );
    } catch (_) {
      centers = [];
    }

    if (!mounted) return;

    setState(() {
      loadingCenters = false;
    });
  }

  //==========================================================
  // VALIDATION
  //==========================================================

  String? _numberValidator(
    String? value,
    String field,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return "$field is required";
    }

    if (num.tryParse(value) == null) {
      return "Enter a valid number";
    }

    return null;
  }

  String? _incomeValidator(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return "Income is required";
    }

    final income =
        double.tryParse(value);

    if (income == null) {
      return "Enter a valid amount";
    }

    if (income < 0) {
      return "Income cannot be negative";
    }

    return null;
  }

  //==========================================================
  // SUBMIT
  //==========================================================

  void _submitProfile() {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (selectedCenterId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor: errorColor,
          content: Text(
            "Please choose a distribution centre.",
          ),
        ),
      );

      return;
    }

    context
        .read<CrudCubit>()
        .completeProfile(
      {
        "total_members": int.parse(
          membersController.text.trim(),
        ),

        "dependents_count":
            int.parse(
          dependentsController.text
              .trim(),
        ),

        "income_level":
            double.parse(
          incomeController.text.trim(),
        ),

        "disability_present":
            disabilityPresent,

        "center_id":
            selectedCenterId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: backgroundColor,

  appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    foregroundColor: textColor,
    title: const Text(
      "Complete Profile",
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
  ),

  body: BlocConsumer<CrudCubit, AuthState>(
    listener: (context, state) {

      if (state is ProfileCompleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: successColor,
            content: Text(
              "Profile completed successfully.",
            ),
          ),
        );

        Get.offAllNamed(
          "/beneficiaryDashboard",
        );
      }

      if (state is ProfileSavedOffline) {

        setState(() {
          showOfflineBanner = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 4),
            backgroundColor: Colors.orange,
            content: Text(
              "You're offline.\nYour profile was saved locally and will sync automatically.",
            ),
          ),
        );

        Get.offAllNamed(
          "/beneficiaryDashboard",
        );
      }

      if (state is AuthFailure &&
          state.generalError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: errorColor,
            content: Text(
              state.generalError!,
            ),
          ),
        );
      }
    },

    builder: (context, state) {

      return Form(
        key: _formKey,

        child: SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),

          padding:
              const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              if (showOfflineBanner)
                _buildOfflineBanner(),

              const Text(
                "Step 2 of 2",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              ClipRRect(
                borderRadius:
                    BorderRadius.circular(20),
                child:
                    const LinearProgressIndicator(
                  value: 1,
                  minHeight: 8,
                  backgroundColor:
                      Color(0xffECECEC),
                  valueColor:
                      AlwaysStoppedAnimation(
                    primaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius:
                      BorderRadius.circular(
                          20),
                  border: Border.all(
                    color:
                        Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(.03),
                      blurRadius: 10,
                      offset:
                          const Offset(0, 5),
                    ),
                  ],
                ),

                child: Column(
                  children: [

                    CircleAvatar(
                      radius: 34,
                      backgroundColor:
                          primaryColor
                              .withOpacity(.1),

                      child: const Icon(
                        Icons.person_outline,
                        size: 34,
                        color: primaryColor,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Almost There!",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Complete your household information to finish your AidBridge registration.",
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color:
                            textSecondaryColor,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Household Card

              _buildHouseholdCard(),

              const SizedBox(height: 24),

              // Disability Card

              _buildDisabilityCard(),

              const SizedBox(height: 24),

              // Distribution Centre

              _buildCenterCard(),

              const SizedBox(height: 35),

              _buildSubmitButton(state),

              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    },
  ),
  );
}

//==========================================================
// HOUSEHOLD INFORMATION CARD
//==========================================================

Widget _buildHouseholdCard() {
  return _buildSectionCard(
    title: "Household Information",
    icon: Icons.groups_outlined,
    child: Column(
      children: [

        _buildNumberField(
          controller: membersController,
          label: "Household Members",
          icon: Icons.people_outline,
          validator: (value) =>
              _numberValidator(
            value,
            "Household members",
          ),
        ),

        const SizedBox(height: 18),

        _buildNumberField(
          controller: dependentsController,
          label: "Dependents",
          icon: Icons.child_care_outlined,
          validator: (value) =>
              _numberValidator(
            value,
            "Dependents",
          ),
        ),

        const SizedBox(height: 18),

        TextFormField(
          controller: incomeController,
          keyboardType:
              const TextInputType.numberWithOptions(
            decimal: true,
          ),

          validator: _incomeValidator,

          decoration: InputDecoration(
            labelText: "Monthly Income (KES)",

            prefixIcon: const Icon(
              Icons.payments_outlined,
            ),

            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    ),
  );
}

//==========================================================
// DISABILITY CARD
//==========================================================

Widget _buildDisabilityCard() {
  return _buildSectionCard(
    title: "Additional Information",
    icon: Icons.health_and_safety_outlined,

    child: SwitchListTile(
      value: disabilityPresent,

      contentPadding: EdgeInsets.zero,

      activeColor: primaryColor,

      title: const Text(
        "Disability present",
      ),

      subtitle: const Text(
        "Enable if any household member has a disability.",
      ),

      onChanged: (value) {
        setState(() {
          disabilityPresent = value;
        });
      },
    ),
  );
}

//==========================================================
// DISTRIBUTION CENTRE CARD
//==========================================================

Widget _buildCenterCard() {
  return _buildSectionCard(
    title: "Distribution Centre",
    icon: Icons.location_on_outlined,

    child: loadingCenters

        ? const Padding(
            padding: EdgeInsets.all(25),
            child: Center(
              child:
                  CircularProgressIndicator(
                color: primaryColor,
              ),
            ),
          )

        : centers.isEmpty

            ? const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "No active distribution centres found.",
                  style: TextStyle(
                    color: errorColor,
                  ),
                ),
              )

            : DropdownButtonFormField<int>(
                value: selectedCenterId,

                decoration: InputDecoration(
                  labelText:
                      "Select Distribution Centre",

                  prefixIcon: const Icon(
                    Icons.location_city_outlined,
                  ),

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                ),

                validator: (value) {
                  if (value == null) {
                    return "Please select a distribution centre";
                  }

                  return null;
                },

                items: centers.map((center) {
                  return DropdownMenuItem<int>(
                    value: center["id"],

                    child: Text(
                      center["name"],
                    ),
                  );
                }).toList(),

                onChanged: (value) {
                  setState(() {
                    selectedCenterId = value;
                  });
                },
              ),
  );
}
//==========================================================
// REUSABLE SECTION CARD
//==========================================================

Widget _buildSectionCard({
  required String title,
  required IconData icon,
  required Widget child,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    margin: const EdgeInsets.only(bottom: 4),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.grey.shade200,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.03),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          children: [

            Icon(
              icon,
              color: primaryColor,
            ),

            const SizedBox(width: 10),

            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        child,
      ],
    ),
  );
}

//
//==========================================================
// REUSABLE NUMBER FIELD
//==========================================================
//

Widget _buildNumberField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  required String? Function(String?) validator,
}) {
  return TextFormField(
    controller: controller,

    keyboardType: TextInputType.number,

    validator: validator,

    decoration: InputDecoration(
      labelText: label,

      prefixIcon: Icon(icon),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
      ),
    ),
  );
}

//
//==========================================================
// OFFLINE BANNER
//==========================================================
//

Widget _buildOfflineBanner() {
  return Container(
    width: double.infinity,

    margin: const EdgeInsets.only(
      bottom: 22,
    ),

    padding: const EdgeInsets.all(16),

    decoration: BoxDecoration(
      color: Colors.orange.withOpacity(.12),

      borderRadius:
          BorderRadius.circular(14),

      border: Border.all(
        color: Colors.orange,
      ),
    ),

    child: const Row(
      children: [

        Icon(
          Icons.cloud_off,
          color: Colors.orange,
        ),

        SizedBox(width: 12),

        Expanded(
          child: Text(
            "Offline Mode\nAny profile updates will be synchronized automatically once internet becomes available.",
            style: TextStyle(
              color: Colors.orange,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

//
//==========================================================
// SUBMIT BUTTON
//==========================================================
//

Widget _buildSubmitButton(
  AuthState state,
) {
  return SizedBox(
    width: double.infinity,
    height: 56,

    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(14),
        ),
      ),

      onPressed:
          state is AuthLoading
              ? null
              : _submitProfile,

      icon:
          state is AuthLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.check_circle_outline,
                ),

      label: Text(
        state is AuthLoading
            ? "Submitting..."
            : "Finish Setup",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
}