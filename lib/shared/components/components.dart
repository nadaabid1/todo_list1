// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names, avoid_types_as_parameter_names, sort_child_properties_last, body_might_complete_normally_nullable, import_of_legacy_library_into_null_safe, prefer_is_empty
import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/shared/cubit/cubit.dart';

Widget defaultTextFormField({
  required TextEditingController controller,
  required TextInputType type,
  String Function(String?)? onSubmit,
  Function(String)? onChange,
  Function()? onTap,
  required Function validate,
  required String label,
  required IconData prefix,
  bool isPassword = false,
  bool isClickable = true,
  IconData? suffix,
  Function? suffixPressed,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: isPassword,
      onFieldSubmitted: onSubmit,
      onChanged: onChange,
      enabled: isClickable,
      onTap: onTap,
      validator: (v) {
        validate(v);
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          prefix,
        ),
        suffixIcon: suffix != null
            ? IconButton(
                onPressed: () {
                  suffixPressed!();
                },
                icon: Icon(
                  suffix,
                ),
              )
            : null,
        border: const OutlineInputBorder(),
      ),
    );

Widget buildTaskItem(Map model, context) => Dismissible(
      key: Key(model['id'].toString()),
      onDismissed: (direction) {
        AppCubit.get(context).deleteData(id: model['id']);
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40.0,
              child: Text('${model['time']}'),
            ),
            SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${model['title']}',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${model['data']}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
            IconButton(
              icon: Icon(
                Icons.check_box,
                color: Colors.green,
              ),
              onPressed: () {
                AppCubit.get(context)
                    .updateData(status: 'done', id: model['id']);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.archive,
                color: Colors.black,
              ),
              onPressed: () {
                AppCubit.get(context)
                    .updateData(status: 'archive', id: model['id']);
              },
            ),
          ],
        ),
      ),
    );
Widget taskBuilder({
 required List<Map>tasks,
}) => ConditionalBuilder(
            condition: tasks.length > 0 ,
            builder: (context)=>ListView.separated(
                itemBuilder: (context, index) => buildTaskItem(tasks[index],context),
                separatorBuilder: (context, index) => Padding(
                      padding: const EdgeInsetsDirectional.only(start: 20.0),
                      child: Container(
                        width: double.infinity,
                        height: 1.0,
                        color: Colors.grey[300],
                      ),
                    ),
                itemCount: tasks.length),
                fallback: (context)=>Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu,
                      size: 50.0,
                      color: Colors.grey,),
                      Text('No Tasks Yet, Please Add Some Tasks')
                    ],
                  ),
                ),
          );